//
//  Vote.swift
//  Bang
//
//  Created by David Blanck on 1/4/16.
//  Copyright © 2016 VidWare. All rights reserved.
//

import Foundation
import UIKit

class Vote {

    var imageText: String
    var text: String
    var count: Int
    
    init(imageText: String, text: String, count: Int) {
        self.imageText = imageText
        self.text = text
        self.count = count
    }
    
}
