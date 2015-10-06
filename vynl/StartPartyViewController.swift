//
//  StartPartyViewController.swift
//  vynl
//
//  Created by Eric Chen on 10/2/15.
//  Copyright © 2015 Eric Chen. All rights reserved.
//

import UIKit

class StartPartyViewController: VynlDefaultViewController {
    
    @IBOutlet var partyIDTextField: UISingleLineTextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func startPartyPressed(sender: AnyObject) {
        var partyID: String!
        if (self.partyIDTextField.text != nil && self.partyIDTextField.text != "") {
            partyID = self.partyIDTextField.text!
        } else {
           // make party with provided code
            partyID = self.partyIDTextField.placeholder!
        }
        if (checkAlphaNumeric(partyID)) {
            self.activityIndicator.startAnimating()
            self.songManager.makePartyWithID(partyID)
        } else {
            SweetAlert().showAlert("Invalid ID", subTitle: "Please only use A-Z and 0-9", style: AlertStyle.Error)
        }
    }

    @IBAction func backCalled(sender: AnyObject) {
        self.delegate?.dismissCalled();
    }
    
    func checkAlphaNumeric(string: String) -> Bool {
        let letters = NSCharacterSet.letterCharacterSet()
        let digits = NSCharacterSet.decimalDigitCharacterSet()
        for tempChar in string.unicodeScalars {
            if (!letters.longCharacterIsMember(tempChar.value) && !digits.longCharacterIsMember(tempChar.value)) {
                return false
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.songManager.delegate = self
        self.partyIDTextField.placeholder = self.songManager.randomStringWithLength(8)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "makeParty") {
            let controller = segue.destinationViewController as! VynlDefaultViewController
            controller.songManager = self.songManager
            controller.delegate = self.delegate
        }
    }

}

extension StartPartyViewController {
    func songManager(didMakeParty data: [String : AnyObject]) {
        self.activityIndicator.stopAnimating()
        if (data["error"] != nil) {
            SweetAlert().showAlert("Party Already Exists", subTitle: "", style: AlertStyle.Error)
        } else {
            self.performSegueWithIdentifier("makeParty", sender: self)
        }
    }
}
