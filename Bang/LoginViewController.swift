//
//  LoginViewController.swift
//  Bang
//
//  Created by David Blanck on 1/27/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import Foundation

class LoginViewController : PFLogInViewController {
    
    var backgroundImage : UIImageView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "LoginBackground"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        self.logInView!.insertSubview(backgroundImage, atIndex: 0)
        
        // remove the parse Logo
        let logo = UILabel()
        logo.text = "Login"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "System", size: 170)
        logo.shadowColor = UIColor.whiteColor()
        logInView?.logo = logo
        
        // position logo at top with larger frame
        logInView!.logo!.sizeToFit()
        let logoFrame = logInView!.logo!.frame
        logInView!.logo!.frame = CGRectMake(logoFrame.origin.x, logInView!.usernameField!.frame.origin.y - logoFrame.height - 16, logInView!.frame.width,  logoFrame.height)

        logInView?.logInButton?.setBackgroundImage(nil, forState: .Normal)
        logInView?.logInButton?.backgroundColor = UIColor.orangeColor()
        logInView?.passwordForgottenButton?.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        //Setup Forgot Username button
        let forgotUsernameButton = UIButton()
        forgotUsernameButton.setTitle("Forgot Username?", forState: UIControlState.Normal)
        
        forgotUsernameButton.titleLabel!.font = UIFont(name: "System", size: 10.0)
        forgotUsernameButton.addTarget(self, action: "forgotUsernameButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
        
        //Add button to view
        logInView!.addSubview(forgotUsernameButton)
        
        //Setup forgot user button layout
        forgotUsernameButton.translatesAutoresizingMaskIntoConstraints = false
        forgotUsernameButton.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
        forgotUsernameButton.widthAnchor.constraintEqualToAnchor(view.widthAnchor).active = true
        forgotUsernameButton.topAnchor.constraintEqualToAnchor(logInView?.passwordForgottenButton?.bottomAnchor, constant: 10.0).active = true
        forgotUsernameButton.bottomAnchor.constraintEqualToAnchor(logInView?.passwordForgottenButton?.bottomAnchor, constant: 40.0).active = true
        
        
        // make the buttons clear
        customizeButton(logInView?.signUpButton!)
        
        self.signUpController = SignUpViewController()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  self.logInView!.frame.width,  self.logInView!.frame.height)
    }
    
    func customizeButton(button: UIButton!) {
        button.setBackgroundImage(nil, forState: .Normal)
        button.backgroundColor = UIColor.clearColor()
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.whiteColor().CGColor
    }
    
    
    @IBAction func forgotUsernameButtonPressed(sender: UIButton) {
        print("forgot username button pressed")
        
        var inputTextField: UITextField?
        
        let forgotUserNameAlert = UIAlertController(title: "Forgot Username", message: "Enter the email associated to your account", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            print("search for entered email")
            self.findUsernameWithEmail((inputTextField?.text!)!)
        }
        
        forgotUserNameAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
            textField.placeholder = "Enter email"
        }
        forgotUserNameAlert.addAction(cancelAction)
        forgotUserNameAlert.addAction(okAction)
        presentViewController(forgotUserNameAlert, animated: true, completion: nil)
        
        
    }
    
    func findUsernameWithEmail(email: String) {
        print("in search function")
        var title: String!
        var message: String!
        let query = PFQuery(className: "_User")
        query.whereKey("email", equalTo: email)
        query.findObjectsInBackgroundWithBlock { (results: [PFObject]?, error: NSError?) -> Void in
            if error == nil && results?.count > 0 {
                title = "Found Username"
                message = "Your username is:\n\n \(results![0].objectForKey("username") as! String)"
                print(message)
                
                let userNameAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                userNameAlert.addAction(okAction)
                self.presentViewController(userNameAlert, animated: true, completion: nil)
                
                
            } else {
                title = "Username not Found"
                message = "Unable to find your username, please check your email and try again"
                print(message)
                let userNameAlert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                userNameAlert.addAction(okAction)
                self.presentViewController(userNameAlert, animated: true, completion: nil)
            }
        }
        
    }
    
}