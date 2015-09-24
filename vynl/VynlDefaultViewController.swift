//
//  VynlDefaultViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit
import CRToast

class VynlDefaultViewController: UIViewController {

    var songManager: SongManager!
    var delegate: DefaultModalDelegate?
    
    var reconnectAttempts = 0
    var reconnectingOptions: NSDictionary = [
        kCRToastTextKey: "reconnecting...",
        kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
        kCRToastBackgroundColorKey : UIColor.orangeColor(),
        kCRToastAnimationInTypeKey: CRToastAnimationType.Gravity.rawValue,
        kCRToastAnimationOutTypeKey: CRToastAnimationType.Spring.rawValue,
        kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastTimeIntervalKey: DBL_MAX
    ]
    
    var disconnectedOptions: NSMutableDictionary = [
        kCRToastTextKey: "Failed to connect. Tap here to try again",
        kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
        kCRToastBackgroundColorKey : UIColor.redColor(),
        kCRToastAnimationInTypeKey: CRToastAnimationType.Gravity.rawValue,
        kCRToastAnimationOutTypeKey: CRToastAnimationType.Spring.rawValue,
        kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastTimeIntervalKey: DBL_MAX
    ]
    
    var connectedOptions: NSDictionary = [
        kCRToastTextKey: "connected",
        kCRToastTextAlignmentKey: NSTextAlignment.Center.rawValue,
        kCRToastBackgroundColorKey : UIColor.greenColor(),
        kCRToastAnimationInTypeKey: CRToastAnimationType.Gravity.rawValue,
        kCRToastAnimationOutTypeKey: CRToastAnimationType.Spring.rawValue,
        kCRToastAnimationInDirectionKey: CRToastAnimationDirection.Top.rawValue,
        kCRToastAnimationOutDirectionKey: CRToastAnimationDirection.Top.rawValue
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension VynlDefaultViewController: SongManagerDelegate {
    /* after toast finished */
    func finished() {
    }
    
    func reconnect() {
        CRToastManager.showNotificationWithOptions(reconnectingOptions as [NSObject : AnyObject], completionBlock: finished)
        self.songManager.socketHelper.connect()
    }
    
    func songManager(didDisconnect data: [String : AnyObject]) {
        
        var error = data["error"] as! NSError
        if (error.code == 57) {
            var interactionResponder = [CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true, block: {(CRToastInteractionType) in
                self.reconnect()
            })]
            disconnectedOptions[kCRToastInteractionRespondersKey] = interactionResponder
            CRToastManager.showNotificationWithOptions(disconnectedOptions as [NSObject : AnyObject], completionBlock: finished)
        } else if (reconnectAttempts >= 3) {
            var interactionResponder = [CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true, block: {(CRToastInteractionType) in
                self.reconnect()
            })]
            disconnectedOptions[kCRToastInteractionRespondersKey] = interactionResponder
            CRToastManager.showNotificationWithOptions(disconnectedOptions as [NSObject : AnyObject], completionBlock: finished)
            reconnectAttempts = 0
        } else {
            CRToastManager.showNotificationWithOptions(reconnectingOptions as [NSObject : AnyObject], completionBlock: finished)
            self.songManager.socketHelper.connect()
            reconnectAttempts++
        }
        
    }
    
    func songManager(onError data: [String : AnyObject]) {
        var error = data["error"] as! NSError
        println(error.code)
        if (error.code == 57) {
            var interactionResponder = [CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true, block: {(CRToastInteractionType) in
                self.reconnect()
            })]
            disconnectedOptions[kCRToastInteractionRespondersKey] = interactionResponder
            CRToastManager.showNotificationWithOptions(disconnectedOptions as [NSObject : AnyObject], completionBlock: finished)
        } else if (error.code == -6) {
            var interactionResponder = [CRToastInteractionResponder(interactionType: CRToastInteractionType.Tap, automaticallyDismiss: true, block: {(CRToastInteractionType) in
                self.reconnect()
            })]
            disconnectedOptions[kCRToastInteractionRespondersKey] = interactionResponder
            CRToastManager.dismissNotification(true)
            CRToastManager.showNotificationWithOptions(disconnectedOptions as [NSObject : AnyObject], completionBlock: finished)
        }
    }
    
    func songManager(didConnect data: [String : AnyObject]) {
        CRToastManager.dismissNotification(true)
        CRToastManager.showNotificationWithOptions(connectedOptions as [NSObject : AnyObject], completionBlock: finished)
    }
}
