//
//  AvatarCollectionView.swift
//  Bang
//
//  Created by David Blanck on 2/1/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

protocol AvatarCollectionViewDelegate {
    
    func avatarViewCancelButtonPressed()
    func avatarViewDoneButtonPressed()
    func avatarColorButtonSelected(colorSelected: Int)
    func avatarCollectionViewDidSelectItem(avatarChosen: Int)
    func imagesForAvaterCollectionView() -> [String]
    
}

class AvatarCollectionView: UIView {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var avatarCollectionView: UICollectionView!

    @IBOutlet weak var avatarSegmentedControl: UISegmentedControl!
    
    
    var delegate: AvatarCollectionViewDelegate?
    var indexPath: NSIndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Setup collection view
        let layout = self.avatarCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
        
        avatarCollectionView!.dataSource = self
        avatarCollectionView.delegate = self
        avatarCollectionView.backgroundColor = UIColor.whiteColor()
        
        //Setup Bar items
        cancelButton.tintColor = kPurpleColor
        doneButton.tintColor = kPurpleColor
        avatarSegmentedControl.tintColor = UIColor.blackColor()
        avatarSegmentedControl.selectedSegmentIndex = 0
        
        
    }
    
    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        delegate?.avatarViewCancelButtonPressed()
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        delegate?.avatarViewDoneButtonPressed()
    }
    
    @IBAction func avatarSegmentedControlValueChanged(sender: AnyObject) {
        delegate?.avatarColorButtonSelected(avatarSegmentedControl.selectedSegmentIndex)
        avatarCollectionView.reloadData()
    }
    
}

extension AvatarCollectionView: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return (delegate?.imagesForAvaterCollectionView().count)!
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("AvatarCell", forIndexPath: indexPath) as! AvatarCollectionViewCell
        
        cell.avatarImageView.image = UIImage(named: (delegate?.imagesForAvaterCollectionView()[indexPath.row])!)
        
        if cell.selected {
            cell.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        
        return cell
    }
    
    
}

extension AvatarCollectionView: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.lightGrayColor()
        
        delegate?.avatarCollectionViewDidSelectItem(indexPath.row)
        
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.clearColor()
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        //Set size of collection view cells
        return CGSize(width: collectionView.frame.width / 4.0, height: collectionView.frame.width / 4.0)
        
    }
    
    
    
    
    
}





