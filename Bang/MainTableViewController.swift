//
//  MainTableViewController.swift
//  Bang
//
//  Created by David Blanck on 1/10/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

// NEED TO ADD USER VOTE SELECTION TO USER LOG (what did they vote)
// FIX WARNING: There are visible views left after reusing them all

import UIKit
import AVFoundation
import iAd
import Social
import QuartzCore

class MainTableViewController: PFQueryTableViewController {
    
    @IBOutlet var searchView: SearchView!  //View for search bar and selector
    @IBOutlet weak var createBarButton: UIBarButtonItem!
    @IBOutlet weak var rebangBarButton: UIBarButtonItem!
    @IBOutlet weak var rebangBarIconButton: UIBarButtonItem!
    @IBOutlet weak var userBarButton: UIBarButtonItem!
  
    @IBOutlet weak var topBangersBarButton: UIBarButtonItem!
    
    //Create various sounds
    var bangSound: AVAudioPlayer?  //Used when votes are cast
    
    var currentSelectedSegment = 0  // Current selected filter segment
    var searchString = ""  //Current search string
    
    var currentUserVotes: [String] = [] //Local array of current users voted Bangs
    
    //Bool to check if current query is for current user, so user can delete own Bangs
    var isCurrentUserQuery: Bool = false
    
    var selectedRowIndexPath: NSIndexPath? //Selected row in table
    
    //Vote Selections
    var voteSelections: [VoteSelection] = []
    
    //Setup notification center for an observer
    let notificationCenter = NSNotificationCenter.defaultCenter()
    
    

    
    //iAd variables
    var consecutiveVotes = 0
    var nextAdInNumberOfVotes: Int!
    var interAd = ADInterstitialAd()
    var interAdView: UIView = UIView()
    var closeButton = UIButton(type: UIButtonType.System)
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 200
        
        //Setup observer
        notificationCenter.addObserver(self, selector: Selector("applicationWillEnterForegroundNotification"), name: UIApplicationWillEnterForegroundNotification, object: nil)
        
        //Setup observer for reachability status change
        notificationCenter.addObserver(self, selector: "reachabilityStatusChangeMainActions", name: "ReachStatusChange", object: nil)

        //Setup Child back button
        let backButton = UIBarButtonItem()
        backButton.title = ""
        self.navigationItem.backBarButtonItem = backButton
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        //Audio setup
        if let bangSound = self.setupAudioPlayerWithFile(kBangSound, type: "mp3") {
            self.bangSound = bangSound
        }
        
        //Setup various UI elements
        createBarButton.tintColor = UIColor.whiteColor()
        rebangBarButton.tintColor = UIColor.whiteColor()
        topBangersBarButton.tintColor = UIColor.whiteColor()
        rebangBarIconButton.tintColor = UIColor.whiteColor()
        userBarButton.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.barTintColor = kPurpleColor
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //Setup iAd exit button
        closeButton.frame = CGRectMake(15, 15, 30, 30)
        closeButton.layer.cornerRadius = 10
        closeButton.setTitle("X", forState: UIControlState.Normal)
        closeButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        closeButton.backgroundColor = UIColor.whiteColor()
        closeButton.layer.borderColor = UIColor.blackColor().CGColor
        closeButton.layer.borderWidth = 1
        closeButton.addTarget(self, action: "close:", forControlEvents: UIControlEvents.TouchDown)
        
        //Calculate random number of votes for iAd popup
        nextAdInNumberOfVotes = Int(arc4random_uniform(UInt32(kMaximumVotesToiAd - kMinimumVotesToiAd))) + kMinimumVotesToiAd
        
        //Load Topics User already voted on
        currentUserVotes = (PFUser.currentUser()?.objectForKey("votes"))! as! [String]
        
        //update reBang count title
        checkForRebangReload()
        self.rebangBarButton.title = String(PFUser.currentUser()!.objectForKey("reBangs")!)
        

        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
        self.loadObjects()
        self.tableView.reloadData()
        self.rebangBarButton.title = String(PFUser.currentUser()!.objectForKey("reBangs")!)
    
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "mainToUserViewSegue" {
            var selectedUser: PFUser
            
            if ((sender?.isKindOfClass(UIBarButtonItem)) != nil){
                selectedUser = PFUser.currentUser()!
            } else {
                let selectedRow = objectAtIndexPath(self.selectedRowIndexPath) as! BangTopic
                selectedUser = selectedRow.user!
            }
            
            // Selected a Row, this will present the UserView for the author of the selected row
            let userViewController = segue.destinationViewController as! UserViewController
            userViewController.currentSelectedUser = selectedUser
            //Populate array of currently selected user's followed users
            if selectedUser.objectForKey("followingUser") != nil {
                userViewController.currentSelectedUser = selectedUser
                let userFollowingArray = selectedUser.objectForKey("followingUser") as! [PFUser]
                userViewController.selectedUserFollowing = userFollowingArray
            } else {
                userViewController.currentSelectedUser = selectedUser
                userViewController.selectedUserFollowing = []
            }

        } else if segue.identifier == "mainToCreateViewSegue" {
            
            //Prepare for Create a new Bang
            let createViewController = segue.destinationViewController as! CreateViewController
             createViewController.voteSelections = voteSelections
        }
    }
    
    //Parse PFQuery for TableViewController
    override func queryForTable() -> PFQuery {
        let query = selectQuery(currentSelectedSegment)
        return query!
    }
    
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {
        //Used in subsequent Views to return to this view
        
        if segue.sourceViewController.isKindOfClass(UserViewController) {
            // Set VC to passed in controllser
            let userViewController = segue.sourceViewController as! UserViewController
            
            //Check if unwind came from userFilterSelected biutton or 'Home' button
            if userViewController.userFilterSelected {
                //Set search string and filter search bar to passed in user
                self.searchString = (userViewController.currentSelectedUser?.username)!
                self.searchView.filterSearchBar.text = (userViewController.currentSelectedUser?.username)!
                //set current selected segment to ALL (0)
                currentSelectedSegment = 0
            }
        }
        
    }
    
    @IBAction func userBarButtonPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("mainToUserViewSegue", sender: sender)
        
    }
    
    @IBAction func rebangBarIconButtonPressed(sender: UIBarButtonItem) {
        openStore()
    }
    
    @IBAction func rebangBarButtonPressed(sender: UIBarButtonItem) {
        openStore()

    }
    
    @IBAction func createBarButtonPressed(sender: UIBarButtonItem) {
        
        //Check if email is verified before going to CreateView
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (_ : PFObject?, error: NSError?) -> Void in
            
            if let verified = PFUser.currentUser()!["emailVerified"] as? Bool {
                if verified == true {
                    print("user email verified")
                    //Ok to goto createview
                    
                    //Load vote selections
                    let query = VoteSelection.query()
                    query!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
                        if error == nil {
                            print("Successfully retrieved \(objects!.count) vote selections")
                            self.voteSelections = objects as! [VoteSelection]
                            self.performSegueWithIdentifier("mainToCreateViewSegue", sender: nil)

                        } else {
                            print("Error retrieving VoteSelections: \(error)")
                            self.showErrorView(error!)
                        }
                    }
                    
                    
                } else {
                    let notVerifiedAlert = UIAlertController(title: "Email not Verified", message: "Your Email has not been verified.  You must have a verified Email address to create new !Bangs", preferredStyle: UIAlertControllerStyle.Alert)
                    let verifyAction = UIAlertAction(title: "Verify", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        //Send verification mail
                        self.verifyEmail()
                        
                    })
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
                    notVerifiedAlert.addAction(verifyAction)
                    notVerifiedAlert.addAction(cancelAction)
                    self.presentViewController(notVerifiedAlert, animated: true, completion: nil )
                    
                }
            } else {
                let notVerifiedAlert = UIAlertController(title: "Email not Verified", message: "Your Email has not been verified.  You must have a verified Email address to create new !Bangs", preferredStyle: UIAlertControllerStyle.Alert)
                let verifyAction = UIAlertAction(title: "Verify", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                    //Send verification mail
                    self.verifyEmail()
                })
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Destructive, handler: nil)
                notVerifiedAlert.addAction(cancelAction)
                notVerifiedAlert.addAction(verifyAction)
                self.presentViewController(notVerifiedAlert, animated: true, completion: nil )
            }
        })
    }
    
    //Helper Functions
    
    //Reachability Status Change Events for View
    func reachabilityStatusChangeMainActions() {
        if reachabilityStatus == kNotReachable {
            print("disable buttons")
            createBarButton.enabled = false
            rebangBarIconButton.enabled = false
            rebangBarButton.enabled = false
            userBarButton.enabled = false
            topBangersBarButton.enabled = false
            self.tableView.allowsSelection = false
            
        } else {
            print("enable buttons")

            createBarButton.enabled = true
            rebangBarIconButton.enabled = true
            rebangBarButton.enabled = true
            userBarButton.enabled = true
            topBangersBarButton.enabled = true
            self.tableView.allowsSelection = true

        }
    }
    
    // Check to goto store
    
    func openStore() {
        
        let gotoStoreAlert = UIAlertController(title: "Goto Bang Store?", message: "You can purchase more ReBangs and remove ads in the Bang Store.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil)
        let enterStoreAction = UIAlertAction(title: "Enter Store", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            self.performSegueWithIdentifier("mainToStoreSegue", sender: nil)
        }
        gotoStoreAlert.addAction(cancelAlertAction)
        gotoStoreAlert.addAction(enterStoreAction)
        presentViewController(gotoStoreAlert, animated: true, completion: nil)
        
    }
    
    // Verify Email
    
    func verifyEmail() {
        // Resend verification email
        if let email = PFUser.currentUser()?.email {
            PFUser.currentUser()?.email = email+".verify"
            PFUser.currentUser()?.saveInBackgroundWithBlock({ (success, error) -> Void in
                if success {
                    PFUser.currentUser()?.email = email
                    PFUser.currentUser()?.saveEventually()
                    let emailSentAlert = UIAlertController(title: "Verification Email Sent", message: "A verification email has been sent to \(PFUser.currentUser()!.email!).  Please click on the link in the email to verify your account.", preferredStyle: UIAlertControllerStyle.Alert)
                    let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
                    emailSentAlert.addAction(okAction)
                    self.presentViewController(emailSentAlert, animated: true, completion: nil)
                } else {
                    self.showErrorView(error!)
                }
            })
        }
        
        
    }
    
    
    // Setup Queries
    func selectQuery(index: Int) -> PFQuery? {
        
        var query = PFQuery(className: BangTopic.parseClassName())
        
        
        if searchString != "" {
            //Title Query -- non-case sensitive
            let titleQuery = PFQuery(className: BangTopic.parseClassName())
            titleQuery.whereKey("title", matchesRegex: searchString, modifiers: "i")
            
            //Author Query -- non-case sensitive
            let authorQuery = PFQuery(className: BangTopic.parseClassName())
            authorQuery.whereKey("author", matchesRegex: searchString, modifiers: "i")
            
            //Combine as Title "OR" Author
            //This will allow the search field to search Author and Title
            query = PFQuery.orQueryWithSubqueries([titleQuery, authorQuery])
        
        }

        switch index {
        case 0:
            // All non-Deleted Bangs included in query
            query.includeKey("user")
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            query.orderByDescending("createdAt")
            query.orderByDescending("numberOfVotes")
            isCurrentUserQuery = false

        case 1:
            // Trending non-Deleted Bangs included in query
            query.includeKey("user")
            //query.whereKey("numberOfVotes", greaterThanOrEqualTo: kTrendingBangTopicThreshold)
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            query.orderByDescending("voteRate")
            isCurrentUserQuery = false

        
        case 2:
            // New non-Deleted Bangs user has not voted on yet
            query.includeKey("user")
            query.whereKey("objectId", notContainedIn: currentUserVotes)
            //query.whereKey("objectId", greaterThanOrEqualTo: NSDate(timeIntervalSinceNow: (-60 * 60 * 24 * kNewBangTopicThreshold)))
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            query.orderByDescending("createdAt")
            isCurrentUserQuery = false


        case 3:
            // User non-deleted Bangs
            query.includeKey("user")
            query.whereKey("user", equalTo: PFUser.currentUser()!)
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            query.orderByDescending("createdAt")
            isCurrentUserQuery = true
            
        case 4:
            // Users Followed users non-Deleted Bangs
            query.includeKey("user")
            query.whereKey("user", containedIn: (PFUser.currentUser()?.objectForKey("followingUser"))! as! [AnyObject])
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            query.orderByDescending("createdAt")
            isCurrentUserQuery = false
            
        case 5: // NOT USED
            // New non-Deleted Bangs created in the last "kNewBangTopicTheshold" days
            query.includeKey("user")
            query.whereKey("createdAt", greaterThanOrEqualTo: NSDate(timeIntervalSinceNow: (-60 * 60 * 24 * kNewBangTopicThreshold)))
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            query.orderByDescending("createdAt")
            isCurrentUserQuery = false
            
        default:
            // Default All non-deleted Bangs - Should not be called
            query.includeKey("user")
            query.whereKey("isDeleted", equalTo: NSNumber(bool: false))
            print("All Bangs but missed case")
            isCurrentUserQuery = false
        }
    
        return query
    }
    
    //Determine if voted, rebanged or canceled
    func castVote(selectedBangTopic: BangTopic, voteText: String, indexPath: NSIndexPath) {
        
        if voteText == "tweet" || voteText == "facebook" {
            print("\(voteText) pressed")
            
            //Capture and create image
            let view = tableView.cellForRowAtIndexPath(indexPath)?.contentView
            
            UIGraphicsBeginImageContextWithOptions((view!.frame.size), false, 0.0)
            view?.drawViewHierarchyInRect((view?.bounds)!, afterScreenUpdates: true)
            var capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //Create tweet or facebook post
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) && voteText == "tweet" {
                //Size image for tweet
                capturedImage = resizeImage(capturedImage, newSize: CGSize(width: 400, height: 220))
                
                //Setup Tweet
                let tweetSheet: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
                
                tweetSheet.setInitialText("Check out this !Bang\n")
                tweetSheet.addURL(NSURL(string: kAppURLString))
                tweetSheet.addImage(capturedImage)
                
                self.presentViewController(tweetSheet, animated: true, completion: { () -> Void in
                    print("twitter completion")
                })
            } else if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) && voteText == "facebook" {
                //Setup Facebook post
                let fbPost: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                
                fbPost.addImage(capturedImage)
                self.presentViewController(fbPost, animated: true, completion: { () -> Void in
                    print("FB Post completion")
                })
                
                
            } else {
                //Not available
                var sorryAlertView = UIAlertController()
                if voteText == "tweet" {
                    sorryAlertView = UIAlertController(title: "Twitter not enabled", message: "You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup", preferredStyle: UIAlertControllerStyle.Alert)
                    print("no tweet")
                } else {
                    sorryAlertView = UIAlertController(title: "Facebook not enabled", message: "You can't post to Facebook right now, make sure your device has an internet connection and you have at least one Facebook account setup", preferredStyle: UIAlertControllerStyle.Alert)
                    print("no FB")
                }
                
                let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                sorryAlertView.addAction(okAlertAction)
                self.presentViewController(sorryAlertView, animated: true, completion: nil)
            }
            
            
        } else {
            if currentUserVotes.contains(selectedBangTopic.objectId!) {
                if PFUser.currentUser()?.objectForKey("reBangs") as! Int > 0 {
                    // Rebang or not
                    let voteAlert = UIAlertController(title: selectedBangTopic.title, message: "re!Bang '\(selectedBangTopic.voteSelectionTitles![voteText]!)' on \(selectedBangTopic.title!)?  This will use 1 of your \(PFUser.currentUser()?.objectForKey("reBangs") as! Int) reBangs.", preferredStyle: UIAlertControllerStyle.Alert)
                    let reBang = UIAlertAction(title: "re!Bang", style: UIAlertActionStyle.Destructive) { _ in
                        //Call logVote
                        self.logVote(selectedBangTopic, selectedVote: voteText, indexPath: indexPath, didReBang: true)
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { _ in
                        //Decided not to rebang
                    }
                    voteAlert.addAction(cancel)
                    voteAlert.addAction(reBang)
                    presentViewController(voteAlert, animated: true, completion: nil)
                    
                } else {
                    // No rebangs left
                    let voteAlert = UIAlertController(title: selectedBangTopic.title, message: "You already voted on \(selectedBangTopic.title!) and have no reBangs left. Goto the !Bang store to purchase ReBangs", preferredStyle: UIAlertControllerStyle.Alert)
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { _ in
                        print("no rebangs left")
                    }
                    let enterStore = UIAlertAction(title: "Enter Store", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                        self.performSegueWithIdentifier("mainToStoreSegue", sender: nil)
                    })
                    voteAlert.addAction(cancel)
                    voteAlert.addAction(enterStore)
                    presentViewController(voteAlert, animated: true, completion: nil)
                }
            } else {
                if voteText == "pass" {
                    // Passed vote
                    let voteAlert = UIAlertController(title: selectedBangTopic.title, message: "Pass on Voting on \(selectedBangTopic.title!)?", preferredStyle: UIAlertControllerStyle.Alert)
                    let pass = UIAlertAction(title: "Pass", style: UIAlertActionStyle.Destructive) { _ in
                        //Call logVote
                        self.logVote(selectedBangTopic, selectedVote: voteText, indexPath: indexPath, didReBang: false)
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { _ in
                        //Decided not to vote
                    }
                    voteAlert.addAction(cancel)
                    voteAlert.addAction(pass)
                    presentViewController(voteAlert, animated: true, completion: nil)
                } else {
                    // First time vote
                    let voteAlert = UIAlertController(title: selectedBangTopic.title, message: "!Bang '\(selectedBangTopic.voteSelectionTitles![voteText]!)' on \(selectedBangTopic.title!)?", preferredStyle: UIAlertControllerStyle.Alert)
                    let bang = UIAlertAction(title: "!Bang", style: UIAlertActionStyle.Default) { _ in
                        //Call logVote
                        self.logVote(selectedBangTopic, selectedVote: voteText, indexPath: indexPath, didReBang: false)
                    }
                    let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { _ in
                        //Decided not to vote
                    }
                    voteAlert.addAction(cancel)
                    voteAlert.addAction(bang)
                    presentViewController(voteAlert, animated: true, completion: nil)
                }
                
            }
        }
    }
    
    //Log vote data into Parse
    func logVote(selectedBangTopic: BangTopic, selectedVote: String, indexPath: NSIndexPath, didReBang: Bool) {
 
        if selectedVote != "pass" {
            //Log vote data
            
            //Update Bang Topic Vote and Author vote count
            selectedBangTopic.incrementKey("numberOfVotes")
            selectedBangTopic.incrementKey(selectedVote + "Count")
            
            //Save Bang Topic Data
            selectedBangTopic.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    //Play Bang sound
                    self.bangSound?.play()
                } else {
                    print("Error saving", error)
                    self.showErrorView(error!)
                }
            }
            
            //Call Cloud Code to increment vote count for author of voted bang
            let votedUserName = selectedBangTopic.user?.username!
            PFCloud.callFunctionInBackground("incrementUserVote", withParameters: ["username":votedUserName!]) { (response: AnyObject?, error: NSError?) -> Void in
                //print(response)
            }
            
            //Update user data
            //If reBang occured, decrement amount of reBangs left and save user data
            if didReBang {
                PFUser.currentUser()?.incrementKey("reBangs", byAmount: -1)
                self.rebangBarButton.title = String(PFUser.currentUser()!.objectForKey("reBangs")!)
            }
            
        }
        
        //Add vote ID and vote to current user (DOES NOT ADD VOTE YET!!!)
        currentUserVotes.append(selectedBangTopic.objectId!)
        PFUser.currentUser()?.addUniqueObject(selectedBangTopic.objectId!, forKey: "votes")
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        
        //Save PFUser Data
        PFUser.currentUser()?.saveInBackground()
        
        //Increment numberOfVotes for iAd
        consecutiveVotes += 1
        
        if consecutiveVotes == nextAdInNumberOfVotes && PFUser.currentUser()!["isAdFree"] as! Bool == false {
            // Call iAd
            print("Call iAd")
            loadAd()
            consecutiveVotes = 0
        }
    }
    
    
    //Calculate percentages for BangTopic and returns a Dictionary with results
    func calculatePercents(selectedBangTopic: BangTopic) -> [String : Double] {
        
        var percentages: [String : Double] = [:]
        
        if selectedBangTopic.numberOfVotes == 0 {
            percentages[kFirstVote] = 0.0
            percentages[kSecondVote] = 0.0
            percentages[kThirdVote] = 0.0
            percentages[kFourthVote] = 0.0
            percentages[kFifthVote] = 0.0

        } else {
            for var x = 0; x < selectedBangTopic.voteSelectionTitles?.allKeys.count; x += 1 {
                switch x {
                case 0:
                    percentages[kFirstVote] = Double(selectedBangTopic[kFirstVote + "Count"] as! Int) / Double(selectedBangTopic.numberOfVotes!)
                case 1:
                    percentages[kSecondVote] = Double(selectedBangTopic[kSecondVote + "Count"] as! Int) / Double(selectedBangTopic.numberOfVotes!)
                case 2:
                    percentages[kThirdVote] = Double(selectedBangTopic[kThirdVote + "Count"] as! Int) / Double(selectedBangTopic.numberOfVotes!)
                case 3:
                    percentages[kFourthVote] = Double(selectedBangTopic[kFourthVote + "Count"] as! Int) / Double(selectedBangTopic.numberOfVotes!)
                case 4:
                    percentages[kFifthVote] = Double(selectedBangTopic[kFifthVote + "Count"] as! Int) / Double(selectedBangTopic.numberOfVotes!)
                default:
                    print("ERROR: No items")
                }
            }
        }
        
        return percentages
    }
    
    
    
    // MARK: - Table view data source
 
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BangTopicCell", forIndexPath: indexPath) as! BangTopicTableViewCell
       
        
        let currentBangTopicPost = object as! BangTopic
        
        //Set colors
        cell.authorLabel.textColor = UIColor.lightGrayColor()
        cell.numberOfVotesLabel.textColor = UIColor.lightGrayColor()
        cell.bangAgeLabel.textColor = UIColor.lightGrayColor()

        // Configure the cell...
        //cell.titleLabel.text = "! \(currentBangTopicPost.title!)"
        cell.titleTextView.text = "! \(currentBangTopicPost.title!)"
        
        cell.authorLabel.text = "Author: \(currentBangTopicPost.author!)"
        cell.numberOfVotesLabel.text = "!s: " + counterFormatter(Int(currentBangTopicPost.numberOfVotes!))
        let bangCreationDate = currentBangTopicPost.createdAt
        let age = calculateBangAge(bangCreationDate!)
        cell.bangAgeLabel.text = age
        
        
        //Set delegate and indexPath for selecting vote buttons in table
        cell.delegate = self
        cell.indexPath = indexPath
        
        //calculate percentages
        let currentPercentages = calculatePercents(currentBangTopicPost)
        
        //Setup pass button UI settings
        cell.passButton.layer.borderWidth = 1
        cell.passButton.layer.cornerRadius = 10
        cell.passButton.layer.borderColor = kPurpleColor.CGColor
        cell.passButton.setTitleColor(kPurpleColor, forState: UIControlState.Normal)
        cell.passButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        
        //Check if voted, hide percentages and set cell background color if not voted
        if currentUserVotes.contains(currentBangTopicPost.objectId!) {
            cell.firstVotePercentLabel.hidden = false
            cell.secondVotePercentLabel.hidden = false
            cell.thirdVotePercentLabel.hidden = false
            cell.fourthVotePercentLabel.hidden = false
            cell.fifthVotePercentLabel.hidden = false
            
            cell.backgroundColor = UIColor.whiteColor()
            
            cell.passButton.hidden = true

        } else {
            cell.firstVotePercentLabel.hidden = true
            cell.secondVotePercentLabel.hidden = true
            cell.thirdVotePercentLabel.hidden = true
            cell.fourthVotePercentLabel.hidden = true
            cell.fifthVotePercentLabel.hidden = true
            
            cell.backgroundColor = kLightPurpleColor
            
            cell.passButton.hidden = false


        }
        
        //Set Text, Images, and Percentages
        if currentBangTopicPost.voteSelectionTitles![kFirstVote] != nil {
            cell.firstVoteLabel.text = (currentBangTopicPost.voteSelectionTitles![kFirstVote] as! String)
            cell.firstVotePercentLabel.text = String(format: "%.0f", currentPercentages[kFirstVote]! * 100.0) + "%"

            cell.firstVoteButton.hidden = false
            cell.firstVoteButton.setImage(UIImage(named: currentBangTopicPost.voteSelectionImageNames![kFirstVote] as! String), forState: UIControlState.Normal)

        } else {
            cell.firstVoteLabel.text = ""
            cell.firstVotePercentLabel.text = ""

            cell.firstVoteButton.hidden = true
            cell.firstVoteButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        if currentBangTopicPost.voteSelectionTitles![kSecondVote] != nil {
            cell.secondVoteLabel.text = (currentBangTopicPost.voteSelectionTitles![kSecondVote] as! String)
            cell.secondVotePercentLabel.text = String(format: "%.0f", currentPercentages[kSecondVote]! * 100.0) + "%"

            cell.secondVoteButton.hidden = false
            cell.secondVoteButton.setImage(UIImage(named: currentBangTopicPost.voteSelectionImageNames![kSecondVote] as! String), forState: UIControlState.Normal)

        } else {
            cell.secondVoteLabel.text = ""
            cell.secondVotePercentLabel.text = ""
            
            cell.secondVoteButton.hidden = true
            cell.secondVoteButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        if currentBangTopicPost.voteSelectionTitles![kThirdVote] != nil {
            cell.thirdVoteLabel.text = (currentBangTopicPost.voteSelectionTitles![kThirdVote] as! String)
            cell.thirdVotePercentLabel.text = String(format: "%.0f", currentPercentages[kThirdVote]! * 100.0) + "%"
            
            cell.thirdVoteButton.hidden = false
            cell.thirdVoteButton.setImage(UIImage(named: currentBangTopicPost.voteSelectionImageNames![kThirdVote] as! String), forState: UIControlState.Normal)

        } else {
            cell.thirdVoteLabel.text = ""
            cell.thirdVotePercentLabel.text = ""
            
            cell.thirdVoteButton.hidden = true
            cell.thirdVoteButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        if currentBangTopicPost.voteSelectionTitles![kFourthVote] != nil {
            cell.fourthVoteLabel.text = (currentBangTopicPost.voteSelectionTitles![kFourthVote] as! String)
            cell.fourthVotePercentLabel.text = String(format: "%.0f", currentPercentages[kFourthVote]! * 100.0) + "%"
            
            cell.fourthVoteButton.hidden = false
            cell.fourthVoteButton.setImage(UIImage(named: currentBangTopicPost.voteSelectionImageNames![kFourthVote] as! String), forState: UIControlState.Normal)

        } else {
            cell.fourthVoteLabel.text = ""
            cell.fourthVotePercentLabel.text = ""
            
            cell.fourthVoteButton.hidden = true
            cell.fourthVoteButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        if currentBangTopicPost.voteSelectionTitles![kFifthVote] != nil {
            cell.fifthVoteLabel.text = (currentBangTopicPost.voteSelectionTitles![kFifthVote] as! String)
            cell.fifthVotePercentLabel.text = String(format: "%.0f", currentPercentages[kFifthVote]! * 100.0) + "%"
            
            cell.fifthVoteButton.hidden = false
            cell.fifthVoteButton.setImage(UIImage(named: currentBangTopicPost.voteSelectionImageNames![kFifthVote] as! String), forState: UIControlState.Normal)

        } else {
            cell.fifthVoteLabel.text = ""
            cell.fifthVotePercentLabel.text = ""
            
            cell.fifthVoteButton.hidden = true
            cell.fifthVoteButton.setImage(nil, forState: UIControlState.Normal)
        }
        
        
        // This will create a line of x pixels that will be separating the cells
        let separator = UIView(frame: CGRectMake(0,0,cell.frame.width,8))
        separator.backgroundColor = kLightGrayColor
        cell.contentView.addSubview(separator)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if indexPath.row < objects?.count {
            //Set selectedRowindex for subsequent view
            selectedRowIndexPath = indexPath
            performSegueWithIdentifier("mainToUserViewSegue", sender: nil)
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        } else {
            print("Selected end of table")
            self.loadNextPage()

        }
        
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        //Set table separators insets to zero
        tableView.separatorInset = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //setup searchview and set current selected segment
        searchView.filterSegmentedControl.selectedSegmentIndex = currentSelectedSegment
        searchView.delegate = self
        return searchView
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 92.0
    }
    
 
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         return 150
        
    }
    

    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if isCurrentUserQuery {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.Delete {
            //Set object to currently deleted object
            let object = self.objectAtIndexPath(indexPath)
            
            object!["isDeleted"] = true //Set BangTopic to deleted status

            //Save data
            object?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
                if success {
                    //reload objects and table
                    self.loadObjects()
                    self.tableView.reloadData()

                } else {
                    print("error deleting")
                    self.showErrorView(error!)
                }
            })
        }
    }
    
    //Function called when user brings app into foreground
    func applicationWillEnterForegroundNotification() {
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (_ : PFObject?, error: NSError?) -> Void in
            if error == nil {
                self.checkForRebangReload()
                self.rebangBarButton.title = String(PFUser.currentUser()!.objectForKey("reBangs")!)
            } else {
                self.showErrorView(error!)
            }
        })
    }
   
    
    

    //iAd Helper Functions
    func loadAd() {
        print("Load AD")
        interAd = ADInterstitialAd()
        interAd.delegate = self
    }
    
    func close(sender: UIButton) {
        self.closeButton.removeFromSuperview()
        self.interAdView.removeFromSuperview()
        //Calculate random number of votes for iAd popup

    }
    
    //Remove observer
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReachStatusChange", object: nil)
    }
    
}

extension MainTableViewController: SearchViewDelegate {

    func filterSegmentedControlDidChange(selectedIndex: Int) {
        //If the segment changed update and reload data
        currentSelectedSegment = selectedIndex
        self.loadObjects()
    }
    
    func searchContentsDidChange(searchText: String) {
        //If the search content changed update and reload data
        searchString = searchText
        self.loadObjects()
    }
    
}

extension MainTableViewController: BangTopicTableViewCellDelegate {

    //Vote button selected (voteText) on a particular row (indexPath)
    func voteButtonSelected(voteText: String, indexPath: NSIndexPath) {
        //Assign selectedBang
        let selectedBang = self.objectAtIndexPath(indexPath) as! BangTopic
        
        //Call castVote
        castVote(selectedBang, voteText: voteText, indexPath: indexPath)
    }
    
}


// InterstitialAdDelegate
extension MainTableViewController: ADInterstitialAdDelegate {
    
    func interstitialAdDidLoad(interstitialAd: ADInterstitialAd!) {
        
        interAdView = UIView()
        //Set frame to navigationController bounds
        interAdView.frame = (self.navigationController?.view.bounds)!
        
        //Add AdView to navigation controller view
        self.navigationController?.view.addSubview(interAdView)
        
        interAd.presentInView(interAdView)
        UIViewController.prepareInterstitialAds()
        interAdView.addSubview(closeButton)
        
        //Reset iAd vote count and determine next iAd count
        nextAdInNumberOfVotes = Int(arc4random_uniform(UInt32(kMaximumVotesToiAd - kMinimumVotesToiAd + 1))) + kMinimumVotesToiAd
        print(nextAdInNumberOfVotes)
        consecutiveVotes = 0
        
    }
    
    func interstitialAdDidUnload(interstitialAd: ADInterstitialAd!) {
        
        
    }
    
    func interstitialAd(interstitialAd: ADInterstitialAd!, didFailWithError error: NSError!) {
        
        print("Failed to receive Ad")
        print(error.localizedDescription)
        
        closeButton.removeFromSuperview()
        interAdView.removeFromSuperview()
    
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        tableView.reloadData()
    }
    

    
    
    
}



    
    
    



