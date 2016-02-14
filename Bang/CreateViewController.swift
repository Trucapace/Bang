//
//  CreateViewController.swift
//  Bang
//
//  Created by David Blanck on 1/3/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit
import Social

class CreateViewController: UIViewController {

    @IBOutlet weak var bangTitleTextField: UITextField!
    @IBOutlet var collectionPickerView: CollectionPickerView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var requestButton: UIBarButtonItem!
    
    //SlideView variables
    var currentMenuView: UIView?
    var slideView: UIView?
    
    //Selection data
    var pickerSelectionData: PickerSelectionData = PickerSelectionData()
    var currentImageChosen: Int = 0
    var currentTextChosen: Int = 0
    var selectedVoteIndexPath: NSIndexPath!
    var voteInfoText: [String] = []
    var currentSelectedColorIndex: Int = 0
    
    //Vote Selections
    var voteSelections: [VoteSelection]?
    var voteTextArray: [String] = []
    
    //Items for Bangs
    var bangVoteSelections: [Vote] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        bangTitleTextField.delegate = self
        collectionPickerView.delegate = self
        
        //Setup UI Elements
        cancelBarButton.tintColor = UIColor.whiteColor()
        bangTitleTextField.tintColor = kPurpleColor
        postButton.tintColor = kPurpleColor
        requestButton.tintColor = UIColor.whiteColor()
        
        // Setup Views
        //CollectionPickerView
        collectionPickerView.frame = CGRectMake(view.frame.origin.x, view.frame.size.height, view.frame.size.width, view.frame.size.height - 115)
        view.addSubview(collectionPickerView)
        

        //Setup vote text
        for item in voteSelections! {
            voteTextArray.append(item.title!)
        }
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func requestButtonPressed(sender: UIBarButtonItem) {
        
        //Setup AlertView to request a new VoteSelection title
        
        var inputTextField: UITextField?
        
        let newVoteSelectionAlert = UIAlertController(title: "Request New Vote Selection Text", message: "Enter a suggested new Vote Text.  Foul, lewd, direspectful or derogatory words will NOT be accepted and your account will be subject to potential banning.  Your suggestion must be between \(kMinimumVoteTextLength)  and \(kMaximimVoteTextLength) characters", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        let okAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Cancel, handler: nil)

        
        let submitAlertAction = UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            if inputTextField?.text?.characters.count >= kMinimumVoteTextLength && inputTextField?.text?.characters.count <= kMaximimVoteTextLength {
                // Log request
                self.checkAndLogVoteSuggestion((inputTextField?.text)!)
            } else {
                //Alert user imput is out of range
                let outOfRangeAlert = UIAlertController(title: "Invalid Entry", message: "Your suggestion must be between \(kMinimumVoteTextLength)  and \(kMaximimVoteTextLength) characters in length", preferredStyle: UIAlertControllerStyle.Alert)
                outOfRangeAlert.addAction(okAlertAction)
                self.presentViewController(outOfRangeAlert, animated: true, completion: nil )
  
            }
       
        }
        
        newVoteSelectionAlert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            inputTextField = textField
            textField.placeholder = "Enter Suggestion"
        }
        newVoteSelectionAlert.addAction(cancelAlertAction)
        newVoteSelectionAlert.addAction(submitAlertAction)
        presentViewController(newVoteSelectionAlert, animated: true) {
            //Completion block
        }
    
    }
    
    func checkAndLogVoteSuggestion(suggestedText: String) {
        
        let existingSelectionsQuery = PFQuery(className: "VoteSelection")
//        existingSelectionsQuery.whereKey("isActive", equalTo: true)
        
        var statusOfItem = ""
        var messageText: String = ""

        existingSelectionsQuery.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if error == nil {
                for item in objects! {
                    if item["title"] as! String == suggestedText.capitalizedString {
                        statusOfItem = item["status"] as! String
                        print(item["title"])
                    }
                }
                print("status: \(statusOfItem)")
                if statusOfItem == "approved" {
                    //Submission already exists
                    messageText = "'\(suggestedText.capitalizedString)' is already available"
                } else if statusOfItem == "rejected" {
                    //Submission has been rejected
                    messageText = "'\(suggestedText.capitalizedString)' has been reviewed and rejected"
                } else if statusOfItem == "underReview" {
                    //Submission is under review
                    messageText = "'\(suggestedText.capitalizedString)' is under review"
                } else {
                    //Ok to log request
                    let newVoteSelection = VoteSelection(title: suggestedText.capitalizedString, suggestedByUser: PFUser.currentUser()!, suggestedByUserName: (PFUser.currentUser()?.username)!)
                    newVoteSelection.saveEventually()
                    messageText = "'\(suggestedText.capitalizedString)' suggestion logged for review and approval."
                }
                
                let loggedSuggestionAlert = UIAlertController(title: "New Vote Suggestion", message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
                let okAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil )
                loggedSuggestionAlert.addAction(okAlertAction)
                self.presentViewController(loggedSuggestionAlert, animated: true, completion: nil )
                
            }
        }
        
        
        
    }
    
    
    @IBAction func postButtonPressed(sender: UIButton) {
        
        // Ready Check
        guard checkForPostableBang() else {return}
        
        let title = bangTitleTextField.text?.capitalizeFirst
        var voteSelectionTitles: [String:String] = [:]
        var voteSelectionImageNames: [String:String] = [:]
        
        for var x = 0; x < bangVoteSelections.count; x += 1 {
            
            //Set vote titles, image text and vote counts
            switch x {
            case 0:
                voteSelectionTitles[kFirstVote] = bangVoteSelections[x].text
                voteSelectionImageNames[kFirstVote] = bangVoteSelections[x].imageText
              
                //Increment VoteSelection used count
                voteSelections![x].incrementKey("usedCount")
                voteSelections![x].saveEventually()
                
            case 1:
                voteSelectionTitles[kSecondVote] = bangVoteSelections[x].text
                voteSelectionImageNames[kSecondVote] = bangVoteSelections[x].imageText
              
                //Increment VoteSelection used count
                voteSelections![x].incrementKey("usedCount")
                voteSelections![x].saveEventually()

            case 2:
                voteSelectionTitles[kThirdVote] = bangVoteSelections[x].text
                voteSelectionImageNames[kThirdVote] = bangVoteSelections[x].imageText
              
                //Increment VoteSelection used count
                voteSelections![x].incrementKey("usedCount")
                voteSelections![x].saveEventually()

            case 3:
                voteSelectionTitles[kFourthVote] = bangVoteSelections[x].text
                voteSelectionImageNames[kFourthVote] = bangVoteSelections[x].imageText
              
                //Increment VoteSelection used count
                voteSelections![x].incrementKey("usedCount")
                voteSelections![x].saveEventually()

            case 4:
                voteSelectionTitles[kFifthVote] = bangVoteSelections[x].text
                voteSelectionImageNames[kFifthVote] = bangVoteSelections[x].imageText
            
                //Increment VoteSelection used count
                voteSelections![x].incrementKey("usedCount")
                voteSelections![x].saveEventually()

            default:
                print("ERROR: Not found")
            }
        }
        
    
        //Create newBangTopic
        let newBangTopic = BangTopic(title: title!, author: (PFUser.currentUser()?.username)!, user: PFUser.currentUser()!, voteSelectionTitles: voteSelectionTitles, voteSelectionImageNames: voteSelectionImageNames)
        
        //Save newBangTopic to Parse
        newBangTopic.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            guard success else {
                print("%@", error)
                self.showErrorView(error!)
                return
            }
            print("Bang Object Created with id: \(newBangTopic.objectId)")
            //Push announcement to users subscribe to user's channel
            let push = PFPush()
            let data = ["alert" : "\(PFUser.currentUser()!.username!) just posted a new !Bang: '\(newBangTopic.title!)'. Go vote now!", "badge" : "Increment"]
            push.setChannel(PFUser.currentUser()?.username)
            push.setData(data)
            push.sendPushInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
                if success {
                    print("Push sent to subscribers")
                } else {
                    print("Error pushing: \(error)")
                    self.showErrorView(error!)
                }
            }
            
            let postedAlert = UIAlertController(title: "New !Bang Posted", message: "Your new !Bang \(newBangTopic.title!) was succesfully posted.", preferredStyle: UIAlertControllerStyle.Alert)
            let okAlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })
            let ok2AlertAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            })

            let tweetAlertAction = UIAlertAction(title: "Tweet", style: UIAlertActionStyle.Default, handler: { (UIAlertAction) -> Void in
                
                if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
                    let tweetSheet: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)

                    tweetSheet.setInitialText("I just created a new !Bang,\n!\(newBangTopic.title!).\nGo vote on it now!\n")
                    tweetSheet.addURL(NSURL(string: kAppURLString))
                    tweetSheet.addImage(UIImage(named: "Icon-40.png"))
                    
                    tweetSheet.completionHandler = {
                        (result:SLComposeViewControllerResult) in
                        tweetSheet.dismissViewControllerAnimated(true, completion: nil)
                        self.navigationController?.popViewControllerAnimated(true)
                    }
                    
                    self.presentViewController(tweetSheet, animated: true, completion: { () -> Void in
                        print("twitter completion")
                    })
                    
                } else {
                    let sorryAlertView = UIAlertController(title: "Twitter not enabled", message: "You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup", preferredStyle: UIAlertControllerStyle.Alert)
                    print("no tweet")
                    sorryAlertView.addAction(ok2AlertAction)
                    self.presentViewController(sorryAlertView, animated: true, completion: nil)
                    
                
                }
    
            })
            
            postedAlert.addAction(okAlertAction)
            postedAlert.addAction(tweetAlertAction)
            self.presentViewController(postedAlert, animated: true, completion: nil)
            
        }
        
        
        
        
        
    }
        
    // Helper Functions
    

    
    //Presents slide in view
    func presentSlideView(menuView: UIView) {
        currentMenuView = menuView
        menuView.superview?.bringSubviewToFront(menuView)
        UIView.animateWithDuration(0.5) { () -> Void in
           menuView.frame = CGRectMake(menuView.frame.origin.x, menuView.frame.origin.y - menuView.frame.size.height, menuView.frame.size.width, menuView.frame.size.height)
        }
    }
    
    //Dismisses slide in view
    func dismissSlideView() {
        UIView.animateWithDuration(0.7) { () -> Void in
            if let slideView = self.currentMenuView {
                self.currentMenuView = nil
                slideView.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.size.height, self.view.frame.size.width, slideView.frame.height)
            }
        }
    }
    
    //Add a vote row
    func addARow() {
        if bangVoteSelections.count < 5 {
            let vote = Vote(imageText: "default", text: "Tap to add icon and text", count: 0)
            bangVoteSelections.append(vote)
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: bangVoteSelections.count - 1, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
            tableView.endUpdates()

        } else {
            let tooManyVotesAlert = UIAlertController(title: "Maximum Vote Selections Met", message: "The maximum number of vote selections is 5.  Delete a vote selection before adding another", preferredStyle: UIAlertControllerStyle.Alert)
            tooManyVotesAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(tooManyVotesAlert, animated: true, completion: nil)
        }
        
    }
    
    func checkForPostableBang() -> Bool {
        
        //Must have at least kMinimumVoteSelections votes
        guard bangVoteSelections.count >= kMinimumVoteSelections else {
            let notReadyAlert = UIAlertController(title: "!Bang Not Ready", message: "Your !Bang is not complete. \n Please add at least \(kMinimumVoteSelections) vote options before posting.", preferredStyle: UIAlertControllerStyle.Alert)
            notReadyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(notReadyAlert, animated: true, completion: nil)
            return false
        }
        
        //No title entered
        guard bangTitleTextField.text != "" else {
            let notReadyAlert = UIAlertController(title: "!Bang Not Ready", message: "Your !Bang is not complete. \n Please add a TITLE before posting.", preferredStyle: UIAlertControllerStyle.Alert)
            notReadyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
            presentViewController(notReadyAlert, animated: true, completion: nil)
            return false
        }
        
        for item in bangVoteSelections {
            //No image chosen for all vote selections
            guard item.imageText != "default" else {
                let notReadyAlert = UIAlertController(title: "!Bang Not Ready", message: "Your !Bang is not complete. \n Please choose an IMAGE and TEXT for all vote selections before posting", preferredStyle: UIAlertControllerStyle.Alert)
                notReadyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(notReadyAlert, animated: true, completion: nil)
                return false
            }
            
            //No text chosen for all vote selections
            guard item.text != "Tap to add icon and text" else {
                let notReadyAlert = UIAlertController(title: "!Bang Not Ready", message: "Your !Bang is not complete. \n Please choose IMAGE and TEXT for all vote selections before posting.", preferredStyle: UIAlertControllerStyle.Alert)
                notReadyAlert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil))
                presentViewController(notReadyAlert, animated: true, completion: nil)
                return false
            }
        }
        
        return true
        
    }
    
    //Remove observer
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "ReachStatusChange", object: nil)
    }
    
}

// TableView DataSource
extension CreateViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {

        // 2 Sections (votes section, + add a row section)
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return bangVoteSelections.count
        } else {
            return 1
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell: DataTableViewCell = tableView.dequeueReusableCellWithIdentifier("DataCell") as! DataTableViewCell
            
            let currentVote = bangVoteSelections[indexPath.row]
            
            if currentVote.text == "Tap to add icon and text" {
                //cell.backgroundColor = UIColor.lightGrayColor()
                cell.voteTextLabel.textColor = UIColor.lightGrayColor()
            } else {
                cell.backgroundColor = UIColor.whiteColor()
                cell.voteTextLabel.textColor = UIColor.blackColor()
            }
            
            cell.voteTextLabel.text = currentVote.text
            cell.voteImage.image = UIImage(named: currentVote.imageText)
            return cell
            
        } else if indexPath.section == 1 {
            let cell: AddTableViewCell = tableView.dequeueReusableCellWithIdentifier("AddCell") as! AddTableViewCell
            cell.delegate = self
            return cell
        }
        //return generic cell
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            return true
        } else if indexPath.section == 1 {
            return false
        } else {
            return false
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
      
            if editingStyle == UITableViewCellEditingStyle.Delete {
                // Delete row
                tableView.beginUpdates()
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                bangVoteSelections.removeAtIndex(indexPath.row)
                tableView.endUpdates()
            }

    }
    
    
    

    

    
}


// TableView Delegate
extension CreateViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if tableView.editing {
            return UITableViewCellEditingStyle.None
        } else {
            return UITableViewCellEditingStyle.Delete
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            bangTitleTextField.resignFirstResponder()
            selectedVoteIndexPath = indexPath
            tableView.allowsSelection = false
            slideView = collectionPickerView
            presentSlideView(slideView!)
        } else if indexPath.section == 1 {
            addARow()
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

    }
    
    
}


// TextField Delegate
extension CreateViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if bangTitleTextField.text != "" {
            // capture text field
        } else {
            print("No Title Entered")
        }
        return false
    }
    
}


// CollectionPickerViewDelgate
extension CreateViewController: CollectionPickerViewDelegate {
    

    func cancelPressed() {
        tableView.allowsSelection = true
        dismissSlideView()
    }
    
    func donePressed() {
        //Capture selections from Collection/PickerView
        
        switch currentSelectedColorIndex {
        case 0:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.yellowEmoticons[currentImageChosen]
        case 1:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.greenEmoticons[currentImageChosen]
        case 2:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.blueEmoticons[currentImageChosen]
        case 3:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.violetEmoticons[currentImageChosen]
        case 4:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.blackEmoticons[currentImageChosen]
        case 5:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.whiteEmoticons[currentImageChosen]
        default:
             bangVoteSelections[selectedVoteIndexPath.row].imageText = pickerSelectionData.yellowEmoticons[currentImageChosen]
        }
        
        bangVoteSelections[selectedVoteIndexPath.row].text = voteTextArray[currentTextChosen]
        
        tableView.allowsSelection = true
        dismissSlideView()
        tableView.reloadRowsAtIndexPaths([selectedVoteIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    func colorButtonSelected(colorSelected: Int) {
        //Captures and sets current color selection for emoticons
        
        currentSelectedColorIndex = colorSelected
        
    }
    
    func collectionViewDidSelectItem(itemChosen: Int) {
        currentImageChosen = itemChosen
        
    }
    
    func pickerDidSelectItem(itemSelected: Int) {
        currentTextChosen = itemSelected
    }
    
    func imagesForCollectionView() -> [String] {
        
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
        //return pickerSelectionData.voteImage
    }
    
    func textForPicker() -> [String] {
        return voteTextArray
    }
    
    
}


//AddTableViewCellDelegate
extension CreateViewController: AddTableViewCellDelegate {
    
    func addARowButtonPressed() {
        
        addARow()
        
    }
    
}




















