//
//  TopBangersTableViewController.swift
//  Bang
//
//  Created by David Blanck on 1/19/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

// QUERY LIMIT IS NOT LMITING

import UIKit

class TopBangersTableViewController: PFQueryTableViewController {

    var userRanking: Int = 0
    var selectedUserIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setup swipe back
        let swipeView = UISwipeGestureRecognizer(target: self, action: "respondToSwipe:")
        swipeView.direction = UISwipeGestureRecognizerDirection.Right
        navigationController?.navigationBar.addGestureRecognizer(swipeView)
        
        let secondSwipeView = UISwipeGestureRecognizer(target: self, action: "respondToSwipe:")
        secondSwipeView.direction = UISwipeGestureRecognizerDirection.Right
        tableView.addGestureRecognizer(secondSwipeView)
        
        tableView.delegate = self
        tableView.dataSource = self
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func respondToSwipe(gesture: UISwipeGestureRecognizer) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Go to userDetailView
        if segue.identifier == "topToUserViewSegue" {
            let selectedUser = objectAtIndexPath(selectedUserIndexPath) as! PFUser
            let userViewController = segue.destinationViewController as! UserViewController
            userViewController.currentSelectedUser = selectedUser
        }
    }
    
    
 


    // MARK: - Table view data source

    override func queryForTable() -> PFQuery {
        let query: PFQuery = PFUser.query()!
        query.skip = 0
        query.limit = kNumberOfTopBangers  //Limit is not working
        query.whereKey("isBanned", equalTo: NSNumber(bool: false))
        query.orderByDescending("receivedBangs")

        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject!) -> PFTableViewCell? {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TopCell", forIndexPath: indexPath) as! TopBangerTableViewCell
        
        let currentTopUser = object as! PFUser
 
        //Check and determine ranking of logged in user
        if PFUser.currentUser()?.username == currentTopUser.username {
            cell.backgroundColor = kLightPurpleColor
            self.userRanking = indexPath.row + 1
            
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        cell.rankLabel.text = String(indexPath.row + 1)
        cell.authorLabel.text = currentTopUser.username
        cell.bangsReceivedLabel.text = "!d: " + counterFormatter(currentTopUser.objectForKey("receivedBangs") as! Int)
        cell.avatarImage.image = UIImage(named: currentTopUser.objectForKey("avatarTitle") as! String)
        
        return cell
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableCellWithIdentifier("TopCell") as! TopBangerTableViewCell
        
        let headerBackground = UIView()
        headerBackground.backgroundColor = kLightPurpleColor
        headerView.backgroundView = headerBackground
        
        
        headerView.rankLabel.text = String(userRanking)
        headerView.authorLabel.text = (PFUser.currentUser()?.username)! + " (You)"
        headerView.bangsReceivedLabel.text = "!d: " + counterFormatter(PFUser.currentUser()!.objectForKey("receivedBangs") as! Int)


        
        return headerView
        
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        tableView.separatorInset = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedUserIndexPath = indexPath
        performSegueWithIdentifier("topToUserViewSegue", sender: nil)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        
    }

 


}
