//
//  UISingleLineTextField.swift
//  vynl
//
//  Created by Eric Chen on 7/25/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit

class UISingleLineTextField: UITextField {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 0.5)
        bottomBorder.backgroundColor = UIColor(red: 192/255.0, green: 192/255.0, blue: 192/255.0, alpha: 1.0).CGColor
        self.layer.addSublayer(bottomBorder)
    }

}
