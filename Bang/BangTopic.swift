//
//  BangTopic.swift
//  Bang
//
//  Created by David Blanck on 1/9/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import Foundation

class BangTopic: PFObject, PFSubclassing {
    
    @NSManaged var title: String?
    @NSManaged var author: String?
    @NSManaged var user: PFUser?
    @NSManaged var numberOfVotes: NSNumber?
    @NSManaged var isDeleted: NSNumber?
    @NSManaged var voteSelectionTitles: NSDictionary?
    @NSManaged var voteSelectionImageNames: NSDictionary?
    @NSManaged var firstVoteCount: NSNumber?
    @NSManaged var secondVoteCount: NSNumber?
    @NSManaged var thirdVoteCount: NSNumber?
    @NSManaged var fourthVoteCount: NSNumber?
    @NSManaged var fifthVoteCount: NSNumber?

    
    class func parseClassName() -> String {
        return "BangTopic"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: BangTopic.parseClassName())
        query.includeKey("user")
        query.orderByDescending("createdAt")
        return query
    }
    
    
    
    init(title: String, author: String, user: PFUser, voteSelectionTitles: NSDictionary, voteSelectionImageNames: NSDictionary) {
        super.init()
        
        self.title = title
        self.author = author
        self.user = user
        self.numberOfVotes = 0
        self.isDeleted = false
        self.voteSelectionTitles = voteSelectionTitles
        self.voteSelectionImageNames = voteSelectionImageNames
        self.firstVoteCount = 0
        self.secondVoteCount = 0
        self.thirdVoteCount = 0
        self.fourthVoteCount = 0
        self.fifthVoteCount = 0
        
    }
    
    override init() {
        super.init()
    }
    
    
    
    
}
