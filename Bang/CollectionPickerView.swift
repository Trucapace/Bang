//
//  CollectionPickerView.swift
//  Bang
//
//  Created by David Blanck on 1/17/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

protocol CollectionPickerViewDelegate {
    
    func cancelPressed()
    func donePressed()
    func colorButtonSelected(colorSelected: Int)
    func collectionViewDidSelectItem(itemChosen: Int)
    func pickerDidSelectItem(itemSelected: Int)
    func imagesForCollectionView() -> [String]
    func textForPicker() -> [String]
    
}

class CollectionPickerView: UIView {

    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    @IBOutlet weak var colorSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    
    var delegate: CollectionPickerViewDelegate?
    var indexPath: NSIndexPath?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Setup CollectionView
        let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)
        layout.minimumInteritemSpacing = 0
    
        collectionView!.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.whiteColor()
        
        
        //Setup Bar items
        cancelBarButton.tintColor = kPurpleColor
        doneBarButton.tintColor = kPurpleColor
        colorSegmentedControl.tintColor = UIColor.blackColor()
        colorSegmentedControl.selectedSegmentIndex = 0
        
        
        //Setup PickerView
        pickerView.dataSource = self
        pickerView.delegate = self
        
    }
    
    //Actions
    @IBAction func cancelBarButtonPressed(sender: UIBarButtonItem) {
        delegate?.cancelPressed()
    }
    
    @IBAction func doneBarButtonPressed(sender: UIBarButtonItem) {
        delegate?.donePressed()
    }
    
    
    @IBAction func colorSegmentedControlValueChanged(sender: UISegmentedControl) {
        
        delegate?.colorButtonSelected(colorSegmentedControl.selectedSegmentIndex)
        collectionView.reloadData()
        
    }
    
    
}

// Extensions for Collection
extension CollectionPickerView: UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate?.imagesForCollectionView().count)!

    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("EmoCell", forIndexPath: indexPath) as! EmoticonCollectionViewCell
                
        
        cell.emoticonImageView.image = UIImage(named: (delegate?.imagesForCollectionView()[indexPath.row])!)
        
        
        if cell.selected {
            cell.backgroundColor = UIColor.lightGrayColor()
        } else {
            cell.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    
}

extension CollectionPickerView: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.lightGrayColor()
        
        delegate?.collectionViewDidSelectItem(indexPath.row)
        
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



//Extensions for picker

extension CollectionPickerView: UIPickerViewDataSource {
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return (delegate?.textForPicker().count)!
        
    }
}

extension CollectionPickerView: UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return delegate?.textForPicker()[row]
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
       delegate?.pickerDidSelectItem(row)
        
    }
    
    
}









