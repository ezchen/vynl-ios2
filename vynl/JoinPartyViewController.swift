//
//  JoinPartyViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/25/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit

class JoinPartyViewController: VynlDefaultViewController {

    @IBOutlet var partyIDTextField: UISingleLineTextField!
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Join"
        self.songManager.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func joinPartypressed(sender: AnyObject) {
        self.partyIDTextField.resignFirstResponder()
        self.activityIndicator.startAnimating()
        self.songManager.joinParty(partyIDTextField.text!)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "joinParty") {
            let viewController = segue.destinationViewController as! VynlDefaultViewController
            viewController.songManager = self.songManager
            viewController.delegate = self.delegate
        }
    }
    
    @IBAction func backCalled(sender: AnyObject) {
        self.delegate?.dismissCalled()
    }
}

extension JoinPartyViewController {
    func songManager(didJoin data: [String : AnyObject]) {
        self.activityIndicator.stopAnimating()
        if (data["error"] == nil) {
            print(data["dj"])
            self.performSegueWithIdentifier("joinParty", sender: data)
        }
    }
}