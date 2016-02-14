//
//  StartViewController.swift
//  Bang
//
//  Created by David Blanck on 1/23/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit
import AVFoundation


class StartViewController: UIViewController {
    
    var launchSound: AVAudioPlayer?

    @IBOutlet weak var launchImageView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Do any additional setup after loading the view.

    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        //Launch Sound
        if let launchSound = self.setupAudioPlayerWithFile(kLaunchSound, type: "mp3") {
            self.launchSound = launchSound
        }
        self.launchSound!.play()
        
        //Shake animation
        UIView.animateWithDuration(1.25, delay: 0.0, usingSpringWithDamping: 0.1, initialSpringVelocity: 20, options: UIViewAnimationOptions.CurveEaseOut , animations: {
           
            self.launchImageView.bounds = CGRect(x: self.launchImageView.bounds.origin.x - 20, y: self.launchImageView.bounds.origin.y, width: self.launchImageView.bounds.size.width + 60.0, height:
            self.launchImageView.bounds.size.height)
            }) { (Bool) -> Void in
                //self.performSegueWithIdentifier("startToPreLoginViewSegue", sender: nil)
                self.performSegueWithIdentifier("startToSignInViewSegue", sender: nil)
        }

    }

}
