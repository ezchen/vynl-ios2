//
//  VideoControlsView.swift
//  vynl
//
//  Created by Eric Chen on 9/25/15.
//  Copyright © 2015 Eric Chen. All rights reserved.
//

import UIKit

protocol VideoControlsDelegate {
    func pausePressed()
    func playPressed()
    func skipPressed()
    func sliderValueChanged(sliderValue value: Float)
}

class VideoControlsView: UIView {

    @IBOutlet var skipButton: UIButton!
    @IBOutlet var pauseButton: UIButton!
    @IBOutlet var slider: UISlider!
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    var delegate: VideoControlsDelegate!
    
    var view: VideoControlsView!
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func xibSetup() {
        if (view == nil) {
            view = loadViewFromNib()
        
        
            // use bounds not frame or it'll be offset
            view.frame = bounds
            
            // Make the view stretch with containing view
            view.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
            
            self.slider = view.slider
            self.pauseButton = view.pauseButton
            self.skipButton = view.skipButton
            
            self.slider.setThumbImage(UIImage(named: "handleRectangle"), forState: UIControlState.Normal)
            self.slider.addTarget(self, action: "sliderValueChanged", forControlEvents: UIControlEvents.AllEvents)
            
            self.pauseButton.addTarget(self, action: "pauseButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            
            self.skipButton.addTarget(self, action: "skipButtonPressed", forControlEvents: UIControlEvents.TouchUpInside)
            
            // Adding custom subview on top of our view (over any custom drawing > see note below)
            addSubview(view)
        }
    }
    
    func skipButtonPressed() {
        print("skipButtonPressed")
        self.delegate.skipPressed()
    }
    
    func pauseButtonPressed() {
        print("Pause Button Pressed")
        if (pauseButton.selected) {
            pauseButton.selected = false
            // pause video
            self.delegate.pausePressed()
        } else {
            pauseButton.selected = true
            // play video
            self.delegate.playPressed()
        }
    }
    
    func sliderValueChanged() {
        print(self.slider.value)
        self.delegate.sliderValueChanged(sliderValue: self.slider.value)
    }
    
    func loadViewFromNib() -> VideoControlsView {
        
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "VideoControlsView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! VideoControlsView
        
        return view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }

}
