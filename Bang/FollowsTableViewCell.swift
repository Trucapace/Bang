//
//  FollowsTableViewCell.swift
//  Bang
//
//  Created by David Blanck on 1/21/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

class FollowsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var followImage: UIImageView!
    @IBOutlet weak var followName: UILabel!
    @IBOutlet weak var followBangedCount: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
