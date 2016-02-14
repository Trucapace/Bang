//
//  UserViewController.swift
//  Bang
//
//  Created by David Blanck on 1/20/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit


class UserViewController: UIViewController {
    
    @IBOutlet weak var bangsReceived: UILabel!
    @IBOutlet weak var numberOfFollowers: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameIsFollowing: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var userBangsButton: UIButton!
    
    @IBOutlet var avatarCollectionView: AvatarCollectionView!
    
    var currentSelectedUser: PFUser?
    var nextCurrentSelectedUser: PFUser?
    var isCurrentSelectedUserFollowed: Bool?
    
    var selectedUserFollowing: [PFUser] = []
    
    var selectedUserIndexPath: NSIndexPath?
    
    var userFilterSelected: Bool = false
    
    //Avatar Selection Data
    var pickerSelectionData: PickerSelectionData = PickerSelectionData()
    var currentSelectedColorIndex = 0
    var currentImageChosen: Int = 0
    
    
    //SlideView variables
    var currentMenuView: UIView?
    var slideView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()

        //Setup follow and logout buttons
        followButton.layer.cornerRadius = 10
        followButton.layer.backgroundColor = kPurpleColor.CGColor
        
        logoutButton.layer.cornerRadius = 10
        logoutButton.layer.backgroundColor = kPurpleColor.CGColor
        
        avatarButton.adjustsImageWhenDisabled = false
        
        userBangsButton.layer.cornerRadius = 10
        userBangsButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        userBangsButton.layer.borderWidth = 1
        userBangsButton.layer.borderColor = kPurpleColor.CGColor
        userBangsButton.titleLabel?.adjustsFontSizeToFitWidth = true
        userBangsButton.titleLabel?.minimumScaleFactor = 0.5
        userBangsButton.titleLabel?.numberOfLines = 0
        userBangsButton.titleLabel?.lineBreakMode = NSLineBreakMode.ByClipping
        
        userBangsButton.setTitleColor(kPurpleColor, forState: UIControlState.Normal)
        userBangsButton.titleLabel?.textAlignment = NSTextAlignment.Center

        //Setup swipe back
        let swipeView = UISwipeGestureRecognizer(target: self, action: "respondToSwipe:")
        swipeView.direction = UISwipeGestureRecognizerDirection.Right
        navigationController?.navigationBar.addGestureRecognizer(swipeView)
        
        let secondSwipeView = UISwipeGestureRecognizer(target: self, action: "respondToSwipe:")
        secondSwipeView.direction = UISwipeGestureRecognizerDirection.Right
        tableView.addGestureRecognizer(secondSwipeView)
        
        tableView.delegate = self
        tableView.dataSource = self
        avatarCollectionView.delegate = self
        
        // Setup Views
        // AvatarCollectionView
        avatarCollectionView.frame = CGRectMake(view.frame.origin.x, view.frame.height, view.frame.width, view.frame.height - 75)
        view.addSubview(avatarCollectionView)
        
        //Set logout and follow button if user is viewing own account
        if currentSelectedUser == PFUser.currentUser() {
            logoutButton.hidden = false
            followButton.hidden = true
            avatarButton.enabled = true
        } else {
            logoutButton.hidden = true
            followButton.hidden = false
            avatarButton.enabled = false

        }
        
        //Get an update on the currently logged in user
        PFUser.currentUser()?.fetchInBackgroundWithBlock({ (_: PFObject?, error: NSError?) -> Void in
            // Get selected user's data
            self.currentSelectedUser?.fetchInBackgroundWithBlock({ (user: PFObject?, error: NSError?) -> Void in
                if error == nil {
                    //Set fields with the currenlty selected user
                    if PFUser.currentUser()?.username == self.currentSelectedUser?.username {
                        self.navigationItem.title = (self.currentSelectedUser?["username"] as! String) + " (You)"
                    } else {
                        self.navigationItem.title = (self.currentSelectedUser?["username"] as! String)
                    }
                    
                    self.userNameIsFollowing.text = " \(self.currentSelectedUser?["username"] as! String) is Following:"
                    self.bangsReceived.text = ("Received !s: " + self.counterFormatter(self.currentSelectedUser!.objectForKey("receivedBangs") as! Int))
                    self.numberOfFollowers.text = (self.counterFormatter(self.currentSelectedUser!.objectForKey("numberOfFollowers") as! Int) + " Followers")
                    
                    //Set avatar image
                    if self.currentSelectedUser! == PFUser.currentUser()! && self.currentSelectedUser!["avatarTitle"] as! String == "default" {
                        self.avatarButton.setImage(UIImage(named: "defaultAvatar"), forState: UIControlState.Normal)
                    } else {
                        self.avatarButton.setImage(UIImage(named: self.currentSelectedUser!["avatarTitle"] as! String), forState: UIControlState.Normal)
                    }
                    
                    self.userBangsButton.setTitle("\(self.currentSelectedUser!["username"])'s Bangs", forState: UIControlState.Normal)
                    
                } else {
                    self.showErrorView(error!)
                }
                
                // Check if the logged in user is currently following the selected user
                let currentInstallation = PFInstallation.currentInstallation() 
                
                if (currentInstallation.channels?.contains((self.currentSelectedUser?.username)!))! == true {
                    print("user is subscribed to \(self.currentSelectedUser?.username) channel")
                    self.isCurrentSelectedUserFollowed = true
                    self.followButton.setTitle("Un-Follow", forState: UIControlState.Normal)
                    self.followButton.layer.backgroundColor = UIColor.whiteColor().CGColor
                    self.followButton.setTitleColor(kPurpleColor, forState: UIControlState.Normal)
                    self.followButton.layer.borderWidth = 1
                    self.followButton.layer.borderColor = kPurpleColor.CGColor
                    
                } else {
                    self.isCurrentSelectedUserFollowed = false
                    self.followButton.setTitle("Follow", forState: UIControlState.Normal)
                    self.followButton.layer.backgroundColor = kPurpleColor.CGColor
                    self.followButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
                    self.followButton.layer.borderColor = UIColor.whiteColor().CGColor

                }
                
            })
        })
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        

    
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Function for back swiping
    func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //DidSelectRowAtIndexPath is not needed with this implementation and allows the VC to call itself
        //Check if segue is to self and set the destination view controller to a new instance of UserView Controller
        if segue.identifier == "userToSelfSegue", let destinationVC = segue.destinationViewController as? UserViewController {
            //Check if the send is a tebleView Cell and set the indexPath to the sender cell
            if let cell = sender as? FollowsTableViewCell, let indexPath = tableView.indexPathForCell(cell) {
                //Set current selected user to the selected cell
                let currentSelectedUser = selectedUserFollowing[indexPath.row]
                
                //Set the destination view controller current selected user to the selected cell
                destinationVC.currentSelectedUser = currentSelectedUser
                
                //Check if the selected user followingUser key is nil and setup following array for destination view controller
                if currentSelectedUser.objectForKey("followingUser") != nil {
                    let userFollowingArray = currentSelectedUser.objectForKey("followingUser") as! [PFUser]
                    destinationVC.selectedUserFollowing = userFollowingArray
                } else {
                    destinationVC.selectedUserFollowing = []
                }
            }
        }
        
    }
    

    @IBAction func avatarButtonPressed(sender: UIButton) {
        
        //Present slide view
        slideView = avatarCollectionView
        presentSlideView(slideView!)
    }
    

    @IBAction func followButtonPressed(sender: UIButton) {
        
        if isCurrentSelectedUserFollowed == true {
            print("selected user no longer followed")
            //Selected User no longer followed
            PFUser.currentUser()?.removeObjectsInArray([currentSelectedUser!] , forKey: "followingUser")
            PFUser.currentUser()?.saveInBackground()
            
            //Change button view
            followButton.setTitle("Follow", forState: UIControlState.Normal)
            self.followButton.layer.backgroundColor = kPurpleColor.CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.layer.borderColor = UIColor.whiteColor().CGColor
            self.followButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            isCurrentSelectedUserFollowed = false
            
            //Call cloud Code to decrement follower count for selected user
            let selectedUserName = currentSelectedUser?.username
            PFCloud.callFunctionInBackground("decrementNumberOfFollowers", withParameters: ["username":selectedUserName!]) { (response: AnyObject?, error: NSError?) -> Void in
            }
            
            //UnSubscribe to user's channel
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.removeObject((self.currentSelectedUser?.username)!, forKey: "channels")
            currentInstallation.saveInBackground()
            
        } else {
            print("selected user followed")
            //Selected User Followed
            PFUser.currentUser()?.addUniqueObjectsFromArray([currentSelectedUser!], forKey: "followingUser")
            PFUser.currentUser()?.saveInBackground()
            
            //Change button view
            followButton.setTitle("Un-Follow", forState: UIControlState.Normal)
            self.followButton.layer.backgroundColor = UIColor.whiteColor().CGColor
            self.followButton.layer.borderWidth = 1
            self.followButton.layer.borderColor = kPurpleColor.CGColor
            self.followButton.setTitleColor(kPurpleColor, forState: UIControlState.Normal)
            isCurrentSelectedUserFollowed = true
            
            //Call cloud Code to increment follower count for selected user
            let selectedUserName = currentSelectedUser?.username
            PFCloud.callFunctionInBackground("incrementNumberOfFollowers", withParameters: ["username":selectedUserName!]) { (response: AnyObject?, error: NSError?) -> Void in
            }
            print("added subscriber")
            //Subscribe to user's channel
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.addUniqueObject((self.currentSelectedUser?.username)!, forKey: "channels")
            currentInstallation.saveInBackground()
        }
        
    }

    @IBAction func logoutButtonPressed(sender: UIButton) {
        
        //Remove userdata from installation
        PFInstallation.currentInstallation().removeObjectForKey("user")
        PFInstallation.currentInstallation().removeObjectForKey("channels")
        PFInstallation.currentInstallation().addObjectsFromArray([], forKey: "channels")
        PFInstallation.currentInstallation().saveInBackground()
        
        PFUser.logOut()
        navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func filterOnUserButtonPressed(sender: UIButton) {

        //Unwind to home segue
        userFilterSelected = true
        performSegueWithIdentifier("unwindToHomeSegue", sender: self)
    }
    
    // Helper Function
    
    //Presents slide in view
    func presentSlideView(menuView: UIView) {
        currentMenuView = menuView
        menuView.superview?.bringSubviewToFront(menuView)
        UIView.animateWithDuration(0.5) { () -> Void in
            menuView.frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y - menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height)
        }
    }
    
    //Dismiss slide in view
    func dismissSlideView() {
        UIView.animateWithDuration(0.7) { () -> Void in
            if let slideView = self.currentMenuView {
                self.currentMenuView = nil
                slideView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, slideView.frame.height)
            }
        }
    }
    
}

extension UserViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (selectedUserFollowing.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FollowingCell") as! FollowsTableViewCell
    
        //ERROR - not finding data
        
        selectedUserFollowing[indexPath.row].fetchIfNeededInBackgroundWithBlock { (object: PFObject?, error: NSError?) -> Void in
            if error == nil {
                cell.imageView?.image = UIImage(named: self.selectedUserFollowing[indexPath.row].objectForKey("avatarTitle") as! String)
                cell.followName.text = (self.selectedUserFollowing[indexPath.row].objectForKey("username") as! String)
                cell.followBangedCount.text = "!d: " + self.counterFormatter(self.selectedUserFollowing[indexPath.row].objectForKey("receivedBangs") as! Int)
            } else {
                print("Errror fetching user information \(error)")
                self.showErrorView(error!)
            }
        }
        
        

        
        return cell
    }
    
}

extension UserViewController: UITableViewDelegate {
    
    // No use
    
}

extension UserViewController: AvatarCollectionViewDelegate {
    
    func avatarViewCancelButtonPressed() {
        
        dismissSlideView()
    }
    
    func avatarViewDoneButtonPressed() {
        
        var avatarImageText = "default"
        
        switch currentSelectedColorIndex {
        case 0:
            avatarImageText = pickerSelectionData.yellowEmoticons[currentImageChosen]
            
        case 1:
            avatarImageText = pickerSelectionData.greenEmoticons[currentImageChosen]

        case 2:
            avatarImageText = pickerSelectionData.blueEmoticons[currentImageChosen]

        case 3:
            avatarImageText = pickerSelectionData.violetEmoticons[currentImageChosen]

        case 4:
            avatarImageText = pickerSelectionData.blackEmoticons[currentImageChosen]

        case 5:
            avatarImageText = pickerSelectionData.whiteEmoticons[currentImageChosen]

        default:
            avatarImageText = pickerSelectionData.yellowEmoticons[currentImageChosen]
            
        }
        
        avatarButton.setImage(UIImage(named: avatarImageText), forState: UIControlState.Normal)
        PFUser.currentUser()?.setObject(avatarImageText, forKey: "avatarTitle")
        PFUser.currentUser()?.saveInBackgroundWithBlock({ (success: Bool, error: NSError?) -> Void in
            if success {
                print("Avatar saved")
            } else {
                self.showErrorView(error!)
            }
        })
        
        dismissSlideView()
    }
    
    func avatarCollectionViewDidSelectItem(avatarChosen: Int) {
        currentImageChosen = avatarChosen
    }
    
    func avatarColorButtonSelected(colorSelected: Int) {
        //Captures and sets current color selection for emoticons
        
        currentSelectedColorIndex = colorSelected
    }
    
    
    func imagesForAvaterCollectionView() -> [String] {
        
        //Choose emoticon image set based on current color selection index
        switch currentSelectedColorIndex {
        case 0:
            return pickerSelectionData.yellowEmoticons
            
        case 1:
            return pickerSelectionData.greenEmoticons
            
        case 2:
            return pickerSelectionData.blueEmoticons
            
        case 3:
            return pickerSelectionData.violetEmoticons
            
        case 4:
            return pickerSelectionData.blackEmoticons
            
        case 5:
            return pickerSelectionData.whiteEmoticons
            
        default:
            return pickerSelectionData.yellowEmoticons
            
        }
    }
}





