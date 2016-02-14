//
//  SignUpViewController.swift
//  Bang
//
//  Created by David Blanck on 1/27/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

class SignUpViewController : PFSignUpViewController {
    
    var backgroundImage : UIImageView!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set our custom background image
        backgroundImage = UIImageView(image: UIImage(named: "LoginBackground"))
        backgroundImage.contentMode = UIViewContentMode.ScaleAspectFill
        signUpView!.insertSubview(backgroundImage, atIndex: 0)
        
        // remove the parse Logo
        let logo = UILabel()
        logo.text = "Signup"
        logo.textColor = UIColor.whiteColor()
        logo.font = UIFont(name: "System", size: 70)
        logo.shadowColor = UIColor.lightGrayColor()
        signUpView?.logo = logo
        signUpView?.backgroundColor = UIColor.blackColor()
        
        //Setup transistion animation
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
        
        // Setup signup button
        signUpView?.signUpButton?.setBackgroundImage(nil, forState: .Normal)
        signUpView?.signUpButton?.backgroundColor = UIColor.orangeColor()
        // change dismiss button to say 'Already signed up?'
//        signUpView?.dismissButton!.setTitle("Already signed up?", forState: .Normal)
//        signUpView?.dismissButton!.setImage(nil, forState: .Normal)
        
        // re-layout out dismiss button to be below sign
//        let dismissButtonFrame = signUpView!.dismissButton!.frame
//        signUpView?.dismissButton!.frame = CGRectMake(0, signUpView!.signUpButton!.frame.origin.y + signUpView!.signUpButton!.frame.height + 16.0,  signUpView!.frame.width,  dismissButtonFrame.height)
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // stretch background image to fill screen
        backgroundImage.frame = CGRectMake( 0,  0,  signUpView!.frame.width,  signUpView!.frame.height)
        
        // position logo at top with larger frame
        signUpView!.logo!.sizeToFit()
        let logoFrame = signUpView!.logo!.frame
        signUpView!.logo!.frame = CGRectMake(logoFrame.origin.x, signUpView!.usernameField!.frame.origin.y - logoFrame.height - 16, signUpView!.frame.width,  logoFrame.height)
    }
    
}




