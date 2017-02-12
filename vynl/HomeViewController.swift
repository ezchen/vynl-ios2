//
//  HomeViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/9/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit


class HomeViewController: VynlDefaultViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        UINavigationBar.appearance().barTintColor = UIColor.blackColor()
        songManager = SongManager()
        songManager.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startAPartyPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("startAParty", sender: self)
    }
    
    @IBAction func joinAPartyPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("join", sender: self)
    }
    
    @IBAction func sendFeedbackPressed(sender: AnyObject) {
        Instabug.invoke()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "startAParty") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.viewControllers[0] as! VynlDefaultViewController
            controller.songManager = self.songManager
            controller.delegate = self
        } else if (segue.identifier == "join") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.viewControllers[0] as! VynlDefaultViewController
            controller.songManager = self.songManager
            controller.delegate = self
        }
    }

}

extension HomeViewController: DefaultModalDelegate {
    func dismissCalled() {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.songManager.delegate = self
    }
}

extension HomeViewController {
    func songManager(didMakeParty data:[String: AnyObject]) {
    }
}