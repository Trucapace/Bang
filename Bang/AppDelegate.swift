//
//  AppDelegate.swift
//  Bang
//
//  Created by David Blanck on 1/2/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit
import SystemConfiguration

var reachability: Reachability?
var reachabilityStatus = kReachableWithWiFi

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var internetReach: Reachability?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //Reachability
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reachabilityChanged:", name: kReachabilityChangedNotification, object: nil)
        
        internetReach = Reachability.reachabilityForInternetConnection()
        internetReach?.startNotifier()
        if internetReach != nil {
            self.statusChangeWithReachability(internetReach!)
        }
        
        
        //Enable Parse

        Parse.enableLocalDatastore()
        Parse.setApplicationId("4jXAOS0H4RznaCNQVN4f7H7V29BYYy3dTEGpIqDh", clientKey: "en4tewd5Lv7BiZJK7BCnYLh2WbcXv5YvKWhrtVe7")
        PFTwitterUtils.initializeWithConsumerKey("wx5ONlLgPQxbUxSBISehnjnCy", consumerSecret: "Wp6PQVmDIPnpNqAIlHj41KDqo5C0DBZ0Y0RhcnUIgpCJjcok8r")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions);
        
        // Register for Push Notitications
        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector("backgroundRefreshStatus")
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            var pushPayload = false
            if let options = launchOptions {
                pushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil
            }
            if (preBackgroundPush || oldPushHandlerOnly || pushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        let types: UIUserNotificationType = [.Alert, .Badge, .Sound]
        let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()


        //Check and reset badge icon to zero when app is launched
        if (PFInstallation.currentInstallation().badge != 0) {
            PFInstallation.currentInstallation().badge = 0
            PFInstallation.currentInstallation().saveInBackground()
        }
        

    
        // Override point for customization after application launch.
        return true
    }
    
    func statusChangeWithReachability(currentReachabilityStatus: Reachability) {
        
        let networkStatus: NetworkStatus = currentReachabilityStatus.currentReachabilityStatus()
        
        print("StatusValue \(networkStatus.rawValue)")
        
        if networkStatus.rawValue == NotReachable.rawValue {
            print("Network not reachable")
            reachabilityStatus = kNotReachable
        } else if networkStatus.rawValue == ReachableViaWiFi.rawValue {
            print("Reachable with WiFi")
            reachabilityStatus = kReachableWithWiFi
        } else if networkStatus.rawValue == ReachableViaWWAN.rawValue {
            print("Reachable with WWAN")
            reachabilityStatus = kReachableWithWWAN
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("ReachStatusChange", object: nil )
        
        
    }
    
    func reachabilityChanged(notification: NSNotification) {
        print("reachability status changed")
        reachability = notification.object as? Reachability
        self.statusChangeWithReachability(reachability!)
        
        
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
  
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //Activate FaceBook App events
        FBSDKAppEvents.activateApp()
        
        // Clears out all notifications from Notification Center
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        
        //Check and reset badge icon to zero when app becomes active
        if (PFInstallation.currentInstallation().badge != 0) {
            PFInstallation.currentInstallation().badge = 0
            PFInstallation.currentInstallation().saveInBackground()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: kReachabilityChangedNotification, object: nil )
    }
    
    // Parse: Store the device token and handle the UI for notifications by adding the following to your main app delegate:
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        //installation.channels = []
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
            let installation = PFInstallation.currentInstallation()
            installation.channels = ["simulator"]
            installation.saveInBackground()
            
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
    
    //Facebook setup
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    

}




