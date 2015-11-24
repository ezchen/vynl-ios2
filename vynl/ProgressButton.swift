//
//  ProgressButton.swift
//  vynl
//
//  Created by Eric Chen on 11/8/15.
//  Copyright © 2015 Eric Chen. All rights reserved.
//

class ProgressButton: VynlDefaultButton {

    let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setImage(UIImage(), forState: UIControlState.Disabled)
    }
    
    func startSpinner() {
        self.enabled = false
        spinner.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)
        addSubview(spinner)
        self.bringSubviewToFront(spinner)
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        self.enabled = true
        spinner.removeFromSuperview()
        spinner.stopAnimating()
    }
}
