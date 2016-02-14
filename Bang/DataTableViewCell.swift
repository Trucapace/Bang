//
//  DataTableViewCell.swift
//  Bang
//
//  Created by David Blanck on 1/3/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

class DataTableViewCell: UITableViewCell {
    
    //@IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var voteTextLabel: UILabel!
    @IBOutlet weak var voteImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
