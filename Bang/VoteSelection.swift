//
//  VoteSelection.swift
//  Bang
//
//  Created by David Blanck on 1/24/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import Foundation

class VoteSelection: PFObject, PFSubclassing {
    
    @NSManaged var title: String?
    @NSManaged var usedCount: NSNumber?
    @NSManaged var isActive: NSNumber?
    @NSManaged var status: String?
    @NSManaged var suggestedByUser: PFUser?
    @NSManaged var suggestedByUserName: String?
    
    class func parseClassName() -> String {
        return "VoteSelection"
    }
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: VoteSelection.parseClassName())
        query.whereKey("isActive", equalTo: true)
        query.whereKey("status", equalTo: "approved")
        query.orderByAscending("title")
        return query
    }
    
    init(title: String, suggestedByUser: PFUser, suggestedByUserName: String) {
        super.init()
        
        self.title = title
        self.suggestedByUser = suggestedByUser
        self.suggestedByUserName = suggestedByUserName
        self.usedCount = 0
        self.status = "underReview"
        self.isActive = false
        
        
    }
    
    override init() {
        super.init()
    }
    
}
