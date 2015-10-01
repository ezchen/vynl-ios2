//
//  PartyViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit

class PartyViewController: VynlDefaultViewController {

    /* Container for the actual videoHeaderView */
    @IBOutlet var videoView: UIView!
    
    /* Container for the YTPlayerView */
    var videoHeaderView: VideoHeaderView!
    
    /* View with controls to change state of the video */
    @IBOutlet var videoControlsView: VideoControlsView!
    
    /* Table View With Song Queue */
    @IBOutlet var partyCollectionView: UITableView!
    
    /* True when user is dragging the video panning handle */
    /* video controls view doesn't jump around when user is panning */
    var userIsSeeking: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* display unique party ID for others to join */
        self.title = songManager.getPartyID()
        self.songManager.delegate = self
        
        /* Only Show Video View and VideoControls View if User is DJ */
        if (self.songManager.dj!) {
            self.videoHeaderView = NSBundle.mainBundle().loadNibNamed(
                "VideoHeaderView",
                owner: self,
                options: nil)[0] as! VideoHeaderView
            
            self.videoHeaderView.songManager = self.songManager
            self.videoHeaderView.delegate = self
            videoView.addSubview(videoHeaderView)
            self.videoControlsView.xibSetup()
            self.videoControlsView.delegate = self
        } else {
            videoView.hidden = true
            videoControlsView.hidden = true
        }
        
        
        /* if no songs are present show empty view */
        self.toggleEmptyView(songManager.songs.count == 0);
    }
    
    override func loadView() {
        super.loadView()
        
        partyCollectionView.dataSource = self
        partyCollectionView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        /* open search modal */
        if (segue.identifier == "search") {
            let navigationController = segue.destinationViewController as! UINavigationController
            let viewController = navigationController.viewControllers[0] as! SearchViewController
            
            viewController.songManager = self.songManager
            self.songManager.delegate = nil;
            viewController.delegate = self;
        }
    }
    
    @IBAction func backCalled(sender: AnyObject) {
        // make sure the video stops playing when the dj leaves the party
        
        SweetAlert().showAlert("Are you sure?",
            subTitle: "Your friends need your music",
            style: AlertStyle.Warning,
            buttonTitle: "Cancel",
            buttonColor: UIColor.colorFromRGB(0xD0D0D0),
            otherButtonTitle: "Leave",
            otherButtonColor: UIColor.colorFromRGB(0xDD6B55)) { (isOtherButton) -> Void in
                if (isOtherButton) {
                    SweetAlert().showAlert("Welcome Back!", subTitle: "keep on partying!", style: AlertStyle.Success)
                } else {
                    SweetAlert().showAlert("You Left Your Party :(", subTitle: "you can always rejoin using the 8 digit code", style: AlertStyle.None)
                    self.videoHeaderView.playerView.clearVideo()
                    self.delegate?.dismissCalled()
                }
        }
    }
    
    func toggleEmptyView(isEmpty: Bool) {
        if (isEmpty) {
            let view = NSBundle.mainBundle().loadNibNamed("EmptyPartyView", owner: self, options: nil)[0] as? UIView
            self.partyCollectionView.backgroundView = view
            self.partyCollectionView.separatorStyle = UITableViewCellSeparatorStyle.None
        } else {
            self.partyCollectionView.backgroundView = nil;
            
            if (self.songManager.dj!) {
                videoHeaderView.loadVideo()
            }
            self.partyCollectionView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.partyCollectionView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    /* Converts Float to format Minutes:Seconds (0:00) */
    func convertPlayTimeToMinutes(playTime: Float) -> String {
        let timeLeftInFloat = Float(self.videoHeaderView.playerView.duration()) - playTime
        let timeLeftInt = round(timeLeftInFloat)
        let timeLeftMinutes = Int(timeLeftInt/60)
        let timeLeftSeconds = Int(timeLeftInt%60)
        
        var timeLeft: String!
        if (timeLeftSeconds < 10) {
            timeLeft = String(format: "%d:0%d", arguments: [timeLeftMinutes, timeLeftSeconds])
        } else {
            timeLeft = String(format: "%d:%d", arguments: [timeLeftMinutes, timeLeftSeconds])
        }
        
        return timeLeft
    }
}

extension PartyViewController: DefaultModalDelegate {
    /* search modal is dismissed 
       make sure song queue is updated */
    func dismissCalled() {
        self.songManager.delegate = self;
        self.dismissViewControllerAnimated(true, completion: nil)
        self.partyCollectionView.reloadData()
        toggleEmptyView(songManager.songs.count == 0)
    }
}

extension PartyViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songManager.songs.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        
        cell.preservesSuperviewLayoutMargins = false
        
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("partySongCell") as! UIPartyCollectionViewCell
        cell.configureCell(songManager.songs[indexPath.row])
        cell.songManager = self.songManager
        
        cell.separatorInset = UIEdgeInsetsZero
        
        return cell
    }
}

extension PartyViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "delete", handler:{action, indexpath in
            self.songManager.deleteSong(indexPath.row)
        })
        
        if (self.songManager.dj!) {
            return [deleteAction]
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return self.songManager.dj
    }
}

extension PartyViewController {
    func songManager(songsDidUpdate data: [String : AnyObject]) {
        print("SongManager's songs: ", terminator: "")
        print(songManager.songs, terminator: "")
        self.toggleEmptyView(songManager.songs.count == 0)
        self.partyCollectionView.reloadData()
    }
    
    override func songManager(didConnect data: [String : AnyObject]) {
        /* super class (VynlDefaultViewController.Swift) creates the toast message */
        super.songManager(didConnect: data)
        
        /* rejoin the room on the sockets */
        self.songManager.joinParty(songManager.partyID)
    }
}

extension PartyViewController: VideoHeaderViewDelegate {
    /* pass play time information to video controls to update time */
    func didPlayTime(playTime: Float) {
        /* update the slider if the user isn't panning through the video */
        if (!userIsSeeking) {
            let progress = playTime/Float(self.videoHeaderView.playerView.duration())
            self.videoControlsView.slider.setValue(progress, animated: true)
            
            self.videoControlsView.timeLeft.text = self.convertPlayTimeToMinutes(playTime)
        }
    }
}

extension PartyViewController: VideoControlsDelegate {
    func pausePressed() {
        self.videoHeaderView.pause()
    }
    
    func playPressed() {
        self.videoHeaderView.play()
    }
    
    func skipPressed() {
        self.videoHeaderView.nextSong()
    }
    
    func sliderValueSliding(sliderValue value: Float) {
        userIsSeeking = true
        let seekToTime = value * Float(self.videoHeaderView.playerView.duration())
        self.videoControlsView.timeLeft.text = self.convertPlayTimeToMinutes(seekToTime)
    }
    
    func sliderValueChanged(sliderValue value: Float) {
        let seekToTime = value * Float(self.videoHeaderView.playerView.duration())
        self.videoHeaderView.seeking = true
        self.videoHeaderView.playerView.seekToSeconds(seekToTime, allowSeekAhead: true)
    }
    
    func doneSeeking() {
        userIsSeeking = false
    }
}