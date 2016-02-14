//
//  AddTableViewCell.swift
//  Bang
//
//  Created by David Blanck on 1/3/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

protocol AddTableViewCellDelegate {
    func addARowButtonPressed()
}

class AddTableViewCell: UITableViewCell {
    
    var delegate: AddTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addARowButtonPressed(sender: UIButton) {

        delegate?.addARowButtonPressed()
        
    }
}
