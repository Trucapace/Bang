//
//  BangTopicTableViewCell.swift
//  Bang
//
//  Created by David Blanck on 1/10/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

protocol BangTopicTableViewCellDelegate {
    
    func voteButtonSelected(voteText: String, indexPath: NSIndexPath)
    
}

class BangTopicTableViewCell: PFTableViewCell {

    //@IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextView: UITextView!
    
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var numberOfVotesLabel: UILabel!
    @IBOutlet weak var bangAgeLabel: UILabel!
    
    @IBOutlet weak var firstVoteLabel: UILabel!
    @IBOutlet weak var secondVoteLabel: UILabel!
    @IBOutlet weak var thirdVoteLabel: UILabel!
    @IBOutlet weak var fourthVoteLabel: UILabel!
    @IBOutlet weak var fifthVoteLabel: UILabel!
    
    @IBOutlet weak var firstVotePercentLabel: UILabel!
    @IBOutlet weak var secondVotePercentLabel: UILabel!
    @IBOutlet weak var thirdVotePercentLabel: UILabel!
    @IBOutlet weak var fourthVotePercentLabel: UILabel!
    @IBOutlet weak var fifthVotePercentLabel: UILabel!
    
    
    @IBOutlet weak var firstVoteButton: UIButton!
    @IBOutlet weak var secondVoteButton: UIButton!
    @IBOutlet weak var thirdVoteButton: UIButton!
    @IBOutlet weak var fourthVoteButton: UIButton!
    @IBOutlet weak var fifthVoteButton: UIButton!
    
    @IBOutlet weak var dataView: UIView!
    @IBOutlet weak var picturesView: UIView!
    
    @IBOutlet weak var passButton: UIButton!
    @IBOutlet weak var tweetButton: UIButton!
    @IBOutlet weak var faceBookButton: UIButton!
    
    var delegate: BangTopicTableViewCellDelegate?
    
    var indexPath: NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        titleTextView.editable = false
        titleTextView.dataDetectorTypes = UIDataDetectorTypes.Link
        titleTextView.scrollEnabled = false
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func firstVoteButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected(kFirstVote, indexPath: indexPath!)

    }
    
    @IBAction func secondVoteButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected(kSecondVote, indexPath: indexPath!)

    }
    
    @IBAction func thirdVoteButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected(kThirdVote, indexPath: indexPath!)

    }
    
    @IBAction func fourthVoteButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected(kFourthVote, indexPath: indexPath!)

    }
    
    @IBAction func fifthVoteButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected(kFifthVote, indexPath: indexPath!)

    }
    
    
    @IBAction func passButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected("pass", indexPath: indexPath!)
    }
    
    @IBAction func tweetButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected("tweet", indexPath: indexPath!)
    }
    
    @IBAction func facebookButtonPressed(sender: UIButton) {
        delegate?.voteButtonSelected("facebook", indexPath: indexPath!)
    }
    
    

}
