//
//  ProgressButton.swift
//  vynl
//
//  Created by Eric Chen on 11/8/15.
//  Copyright © 2015 Eric Chen. All rights reserved.
//

class ProgressButton: VynlDefaultButton {

    let spinner = UIActivityIndicatorView()
    
    func startSpinner() {
        spinner.center = self.center
        addSubview(spinner)
        if self.imageView != nil {
            self.imageView!.hidden = true
        }
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.removeFromSuperview()
        spinner.stopAnimating()
    }
}
