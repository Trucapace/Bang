//
//  SignInViewController.swift
//  Bang
//
//  Created by David Blanck on 1/27/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.reachabilityStatusChange()
        
        //Setup observer for reachability status change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityStatusChange", name: "ReachStatusChange", object: nil)
    
        // Check if a User is active or not
        if (PFUser.currentUser() == nil) {
            //Setup and present loginViewController
            let loginViewController = LoginViewController()
            loginViewController.delegate = self
            loginViewController.fields = [.UsernameAndPassword, .LogInButton, .PasswordForgotten, .SignUpButton]
            loginViewController.emailAsUsername = false
            loginViewController.signUpController?.emailAsUsername = false
            loginViewController.signUpController?.delegate = self
            
           
            
                
       
            
            self.presentViewController(loginViewController, animated: false, completion: nil)
        } else {
            PFUser.currentUser()?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    print("from user already logged in")
                    self.performSegueWithIdentifier("signInToMainViewSegue", sender: nil)
                } else {
                    self.showErrorView(error!)
                }

            })
        }
    }
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        print("in login")
        
        //Check if current user has a followingUser key
        if let userFollowingArray = PFUser.currentUser()!["followingUser"] as? [PFUser] {
            //Iterate through array of follingUsers and add respective channels to current installation
            for item in userFollowingArray {
                item.fetchInBackgroundWithBlock({ (object:PFObject?, error: NSError?) -> Void in
                    if error == nil  {
                        print(item["username"])
                        PFInstallation.currentInstallation().addObject(item["username"], forKey: "channels")
                        PFInstallation.currentInstallation().saveInBackground()
                    } else {
                        self.showErrorView(error!)
                    }
                })
            }
        } else {
            print("Error finding user array")

        }
        
        // Add default "global" channel to current installation
        PFInstallation.currentInstallation().addObject("global", forKey: "channels")
        
        //add current username to current installation
        PFInstallation.currentInstallation().setObject(PFUser.currentUser()!, forKey: "user")
        PFInstallation.currentInstallation().saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                print("success updating user followers in installation")
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("Error", error)
                self.showErrorView(error!)

            }
        }

    }
    
    // Used when signing up as a new user (Parse signup, not Facebook login)
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        
        user["reBangs"] = kInitialReBangs
        user["lastRefill"] = NSDate()
        user["receivedBangs"] = 0
        user["numberOfFollowers"] = 0
        user["isBanned"] = false
        user["followingUser"] = []
        user["votes"] = []
        user["daysLoggedInARow"] = 0
        user["email"] = user.email
        user["nickName"] = user.username
        user["avatarTitle"] = "default"
        user["isAdFree"] = false
        
        //Set current user for device installation
        PFInstallation.currentInstallation().setObject(PFUser.currentUser()!, forKey: "user")
        PFInstallation.currentInstallation().setObject([], forKey: "channels")
        PFInstallation.currentInstallation().saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if success {
                user.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                    if success {
                        print("new user didSignUp")
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print("Error saving new user: \(error)")
                        self.showErrorView(error!)
                    }
                }
            } else {
                print("Error Saving CurrentInstallation: \(error)")
            }
        }


        

    }
    
    func reachabilityStatusChange() {
        if reachabilityStatus == kNotReachable {
            print("CALL ALERT")
            let offLineAlert = UIAlertController(title: "Network Connection Issue", message: "You are not currently connected to the internet.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
            offLineAlert.addAction(okAction)
            self.navigationController?.visibleViewController?.presentViewController(offLineAlert, animated: true, completion: nil )
        }
    }
    
    //Remove observer
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReachStatusChange", object: nil)
    }

}