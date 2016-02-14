//
//  SearchView.swift
//  Bang
//
//  Created by David Blanck on 1/11/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import UIKit

protocol SearchViewDelegate {
    
    func filterSegmentedControlDidChange(selectedIndex: Int)
    func searchContentsDidChange(searchText: String)
    
}

class SearchView: UIView {

    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var filterSearchBar: UISearchBar!
    
    var delegate: SearchViewDelegate?
    var searchActive: Bool = false
    
    override func awakeFromNib() {

        filterSearchBar.delegate = self
        
    
        //Setup UI Elements
        filterSegmentedControl.tintColor = kPurpleColor
        filterSearchBar.tintColor = kPurpleColor
        filterSegmentedControl.setFontSize(11.0)
        
        
    }
    
    @IBAction func filterSegmentedControlValueChanged(sender: UISegmentedControl) {
        delegate?.filterSegmentedControlDidChange(filterSegmentedControl.selectedSegmentIndex)
    
    }
    
}

extension SearchView: UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
        filterSearchBar.resignFirstResponder()
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        filterSearchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        delegate?.searchContentsDidChange(filterSearchBar.text!)
        filterSearchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        // Getting ERROR: "There are visible views left after reusing them all"
        delegate?.searchContentsDidChange(searchText)
    }
    
}

extension UISegmentedControl {
    
    func setFontSize(fontSize: CGFloat) {
        
        let normalTextAttributes: [NSObject : AnyObject] = [
            //NSForegroundColorAttributeName: UIColor.blackColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(fontSize, weight: UIFontWeightRegular)
        ]
        
        let boldTextAttributes: [NSObject : AnyObject] = [
            //NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(fontSize, weight: UIFontWeightMedium),
        ]
        
        self.setTitleTextAttributes(normalTextAttributes, forState: .Normal)
        self.setTitleTextAttributes(normalTextAttributes, forState: .Highlighted)
        self.setTitleTextAttributes(boldTextAttributes, forState: .Selected)
    }
}







