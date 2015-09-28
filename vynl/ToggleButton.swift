//
//  ToggleButton.swift
//  vynl
//
//  Created by Eric Chen on 9/28/15.
//  Copyright © 2015 Eric Chen. All rights reserved.
//

import UIKit

class ToggleButton: VynlDefaultButton {

    var image1: UIImage!
    var image2: UIImage!
    
    var active: Bool!
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpImages(image1 image1: UIImage, image2: UIImage) {
        self.image1 = image1
        self.image2 = image2
        self.active = true
    }
    
    func toggle() -> Bool {
        return false
    }
}
