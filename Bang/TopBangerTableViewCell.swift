//
//  TopBangerTableViewCell.swift
//  Bang
//
//  Created by David Blanck on 1/19/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

class TopBangerTableViewCell: PFTableViewCell {
    
    
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var bangsReceivedLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
