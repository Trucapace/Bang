//
//  ProductTableViewCell.swift
//  Bang
//
//  Created by David Blanck on 2/4/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

protocol ProductTableViewCellDelegate {
    func priceButtonPressed(indexPath: NSIndexPath)
}

class ProductTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!
    
    
    var delegate: ProductTableViewCellDelegate?
    var indexPath: NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func priceButtonPressed(sender: UIButton) {
        delegate?.priceButtonPressed(indexPath!)
    }
    
    

}
