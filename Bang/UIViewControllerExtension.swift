//
//  UIViewControllerExtension.swift
//  ParseTutorial
//
//  Created by Ron Kliffer on 3/8/15.
//  Copyright (c) 2015 Ron Kliffer. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


extension UIViewController {
  
    //General error call function
    func showErrorView(error: NSError) {
    if let errorMessage = error.userInfo["error"] as? String {
      let alert = UIAlertController(title: "Error", message: errorMessage.capitalizedString, preferredStyle: UIAlertControllerStyle.Alert)
      alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
      presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    //Format counter data
    func counterFormatter(count: Int) -> String {
        
        if count < 1000 {
            return String(count)
        }
        else if count >= 1_000 && count < 10_000 {
            return String(format:"%.1f", Double(count)/1000.0) + "k"
        }
        else if count >= 10_000 && count < 1_000_000 {
            return String(format:"%.0f", Double(count)/1000.0) + "k"
        }
        else if count >= 1_000_000 && count < 100_000_000 {
            return String(format:"%.1f", Double(count)/1000000.0) + "M"
        }
        else {
            return String(format:"%.0f", Double(count)/1000000.0) + "M"
        }
        
    }
    
    //Check for rebangs
    func checkForRebangReload() {
        
        guard let lastRefill = PFUser.currentUser()?.objectForKey("lastRefill")  else {return}
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        //Set last refill date to text format
        let lastRefillString = dateFormatter.stringFromDate(lastRefill as! NSDate)
        
        //Set today's date to text format
        let todayString = dateFormatter.stringFromDate(NSDate())
        
        //Set yesterday's date to text format
        let yesterday = NSCalendar.currentCalendar().dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])
        let yesterDayString = dateFormatter.stringFromDate(yesterday!)
        
        print("last: \(lastRefillString) today: \(todayString)")
        
        //No ReBangs
        if lastRefillString == todayString {
        
        //If logged in yesterday
        } else if lastRefillString == yesterDayString {
            PFUser.currentUser()!["lastRefill"] = NSDate()
            PFUser.currentUser()?.incrementKey("daysLoggedInARow")
            PFUser.currentUser()?.incrementKey("reBangs", byAmount: kRebangRefill)
            let daysInARow = PFUser.currentUser()!["daysLoggedInARow"] as! Int
            let bonusRebangs = daysInARow * kBonusBangMultiplier
            PFUser.currentUser()?.incrementKey("reBangs", byAmount: bonusRebangs)
            
            let reBangReloadAlert = UIAlertController(title: "More reBangs", message: "Welcome Back, you received \(kRebangRefill) ReBangs for logging in today and \(bonusRebangs) bonus ReBangs for logging in \(daysInARow) days in a row.  Keep it up!", preferredStyle: UIAlertControllerStyle.Alert)
            reBangReloadAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(reBangReloadAlert, animated: true, completion: nil )
            
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Saved")
                } else {
                    print("error", error)
                    self.showErrorView(error!)
                }
            })
        //If logged in more than a day ago
        } else {
            PFUser.currentUser()!["lastRefill"] = NSDate()
            PFUser.currentUser()!["daysLoggedInARow"] = 1
            PFUser.currentUser()?.incrementKey("reBangs", byAmount: kRebangRefill)
            print("Welcome Back, you received \(kRebangRefill) ReBangs for logging in today")
            print("You now have \(PFUser.currentUser()?.objectForKey("reBangs")!) rebangs")
            
            let reBangReloadAlert = UIAlertController(title: "More reBangs", message: "Welcome Back, you received \(kRebangRefill) ReBangs for logging in today!", preferredStyle: UIAlertControllerStyle.Alert)
            reBangReloadAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(reBangReloadAlert, animated: true, completion: nil )
            
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Saved")
                } else {
                    print("error", error)
                    self.showErrorView(error!)
                }
            })
            
        }
        
    }
    
    // Audio Helper Method
    func setupAudioPlayerWithFile(file: NSString, type: NSString) -> AVAudioPlayer? {
        //  You need to know the full path to the sound file, and NSBundle.mainBundle() will tell you where in the project to look. AVAudioPlayer needs to know the path in the form of a URL, so the full path is converted to URL format
        let path = NSBundle.mainBundle().pathForResource(file as String, ofType: type as String)
        let url = NSURL.fileURLWithPath(path!)
        
        //  You’ll notice that audioPlayer is an optional. There may be a condition where an AVAudioPlayer may not be created depending on the device that is trying to instantiate i
        var audioPlayer:AVAudioPlayer?
        
        //  This is where you try to create the AVAudioPlayer. Since creating the object may throw an error, you start the block with the do keyword. Next, you try to create the player. If the player is unable to be created, you then catch error. In this case, an error is just being printed to the console but in a real application, you would place your error handling in that block. This error handling code is new in Swift 2.0.
        do {
            try audioPlayer = AVAudioPlayer(contentsOfURL: url)
        } catch {
            print("Player not available")
        }
        
        return audioPlayer
        
    }
    
    //Calculate age of Bang and return a string
    func calculateBangAge(creationDate: NSDate) -> String {
        var ageString: String = ""

        let elapsedTime = NSDate().timeIntervalSinceDate(creationDate)
        let elapsedDays = Int(elapsedTime / 60.0 / 60.0 / 24)
        
        if elapsedDays < 1 {
            ageString = "New"
        } else {
            ageString = String(elapsedDays) + "d"
        }
        
        return ageString
    }
    

    
    func showAlertAppDelegate(title : String,message : String,buttonTitle : String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //Resize image to a specific height
    func resizeImageToHeight(image: UIImage, newHeight: CGFloat) -> UIImage {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //Resize image to a specific width
    func resizeImageToWidth(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    //Resize image to a specific size
    func resizeImage(image: UIImage, newSize: CGSize) -> (UIImage) {
        let newRect = CGRectIntegral(CGRectMake(0,0, newSize.width, newSize.height))
        let imageRef = image.CGImage
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0)
        let context = UIGraphicsGetCurrentContext()
        
        // Set the quality level to use when rescaling
        CGContextSetInterpolationQuality(context, CGInterpolationQuality.High)
        let flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height)
        
        CGContextConcatCTM(context, flipVertical)
        // Draw into the context; this scales the image
        CGContextDrawImage(context, newRect, imageRef)
        
        let newImageRef = CGBitmapContextCreateImage(context)! as CGImage
        let newImage = UIImage(CGImage: newImageRef)
        
        // Get the resized image from the context and a UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
  
    
}


//Extension to capitalize the first letter in a sentance
extension String {
    
    var capitalizeFirst: String {
        if isEmpty { return "" }
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).uppercaseString)
        return result
    }
    
}

