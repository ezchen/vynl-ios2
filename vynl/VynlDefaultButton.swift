//
//  VynlDefaultButton.swift
//  vynl
//
//  Created by Eric Chen on 7/17/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

class VynlDefaultButton: UIButton {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setTitleColor(UIColor.lightGrayColor(), forState: UIControlState.Highlighted)
    }
}
