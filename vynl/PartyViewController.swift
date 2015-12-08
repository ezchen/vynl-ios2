//
//  PartyViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit
import MediaPlayer

class PartyViewController: VynlDefaultViewController {

    /** Container for the actual videoHeaderView */
    @IBOutlet var videoView: UIView!
    
    /** Parent View for the YTPlayerView */
    var videoHeaderView: VideoHeaderView!
    
    /** View with controls to change state of the video */
    @IBOutlet var videoControlsView: VideoControlsView!
    
    /** Table View With list of Song Queue */
    @IBOutlet var partyCollectionView: UITableView!
    
    /** Video View Width Constraint */
    @IBOutlet var videoViewWidthConstraint: NSLayoutConstraint!
    
    /** Video View Bottom Space Constraint */
    @IBOutlet var videoViewBottomSpaceConstraint: NSLayoutConstraint!
    
    /** Video View Height Constraint */
    @IBOutlet var videoViewHeightConstraint: NSLayoutConstraint!
    
    /** Video Controls View bottom space constraint */
    @IBOutlet var videoControlsViewBottomSpaceConstraint: NSLayoutConstraint!
    
    /** party collection view top space constraint */
    @IBOutlet var partyCollectionViewTopSpaceConstraint: NSLayoutConstraint!
    
    var fullScreen = false
    
    /** True when user is dragging the video panning handle. Used so that the
    video controls view doesn't jump around when user is panning */
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
            videoHeaderView.userInteractionEnabled = false
            self.videoControlsView.xibSetup()
            self.videoControlsView.delegate = self
            
            setupBackgroundPlaybackButtons()
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
                    SweetAlert().showAlert("You Left Your Party :(", subTitle: "you can always rejoin using the party ID", style: AlertStyle.None)
                    
                    if (self.songManager.dj!) {
                        self.pausePressed()
                        //self.videoHeaderView.removeFromSuperview()
                        self.videoHeaderView.playerView.clearVideo()
                        
                    }
                    
                    self.delegate?.dismissCalled()
                }
        }
    }
    
    /** Shows empty background view if isEmpty is true */
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
    
    /** Converts Float to format Minutes:Seconds (0:00) */
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
    
    /** Registers buttons for background playback */
    private func setupBackgroundPlaybackButtons() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.addTarget(self, action: "playPressed")
        commandCenter.pauseCommand.addTarget(self, action: "pausePressed")
        commandCenter.nextTrackCommand.addTarget(self, action: "skipPressed")
    }
    
    /** Unregisters buttons for background playback */
    private func deleteBackgroundPlaybackButtons() {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter()
        commandCenter.playCommand.removeTarget(self, action: "playPressed")
        commandCenter.pauseCommand.removeTarget(self, action: "pausePressed")
        commandCenter.nextTrackCommand.removeTarget(self, action: "skipPressed")
    }
    
    @IBAction func handleTap(recognizer: UITapGestureRecognizer) {
        if (!fullScreen) {
            let screenRect = UIScreen.mainScreen().bounds
            let screenWidth = screenRect.size.width
            let screenHeight = screenRect.size.height
            
            let navbarHeight = self.navigationController!.navigationBar.frame.size.height
            let statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
            
            self.videoViewWidthConstraint.constant = screenWidth
            let newVideoHeight = screenWidth * (9.0/16.0)
            self.videoViewHeightConstraint.constant = newVideoHeight
            
            let newBottomSpaceConstraint = screenHeight - newVideoHeight - navbarHeight - statusBarHeight
            self.videoViewBottomSpaceConstraint.constant = newBottomSpaceConstraint
            self.videoControlsViewBottomSpaceConstraint.constant = newBottomSpaceConstraint - videoControlsView.frame.size.height
            
            partyCollectionViewTopSpaceConstraint.constant = screenHeight - newBottomSpaceConstraint - statusBarHeight
            
            self.videoHeaderView.playerView.frame.size.width = screenWidth
            self.videoHeaderView.playerView.frame.size.height = newVideoHeight
            fullScreen = true
            UIView.animateWithDuration(0.5, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.videoViewWidthConstraint.constant = 160
            self.videoViewHeightConstraint.constant = 90
            self.videoViewBottomSpaceConstraint.constant = 45
            self.videoControlsViewBottomSpaceConstraint.constant = 0
            
            partyCollectionViewTopSpaceConstraint.constant = 0
            fullScreen = false
            
            func finished(completed: Bool) {
                self.videoHeaderView.playerView.frame.size.width = 160
                self.videoHeaderView.playerView.frame.size.height = 90
            }
            UIView.animateWithDuration(0.5, animations: {
                self.view.layoutIfNeeded()
                }, completion: finished)
        }
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
        if (self.songManager.dj!) {
            if (songManager.songs.count != 0 && videoHeaderView.state == YTPlayerState.Ended) {
                videoHeaderView.nextSong()
            }
        }
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
        
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, canPerformAction action: Selector, forRowAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return self.songManager.dj
    }
}

extension PartyViewController {
    func songManager(songsDidUpdate data: [String : AnyObject]) {
        print("SongManager's songs: ", terminator: "")
        print(songManager.songs, terminator: "")
        
        if UIApplication.sharedApplication().applicationState != UIApplicationState.Active {
            let notification = UILocalNotification()
            notification.alertTitle = "Keep Vynl open to update the song queue!"
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
        }
        self.toggleEmptyView(songManager.songs.count == 0)
        self.partyCollectionView.reloadData()
        
        if (songManager.dj!) {
            var songs = [String]()
            for song in songManager.songs {
                if let videoID = song["videoID"] as? String {
                    songs.append(videoID)
                }
            }
            if (videoHeaderView.state == YTPlayerState.Ended) {
                videoHeaderView.nextSong()
            }
        }
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
    // Button is now in paused state
    func pausePressed() {
        // When button is in paused state, videos should not automatically play even
        // if queue is ended
        self.videoHeaderView.autoplay = false
        
        self.videoHeaderView.pause()
    }
    
    // Button is now in play state
    func playPressed() {
        // When button is in play state, videos should automatically play even
        // if queue is ended
        self.videoHeaderView.autoplay = true
        
        self.videoHeaderView.play()
    }
    
    func skipPressed() {
        self.videoHeaderView.nextSong()
    }
    
    func sliderValueSliding(sliderValue value: Float) {
        // user is currently panning for the time
        // update the time on video controls view, but not the video yet
        userIsSeeking = true
        let seekToTime = value * Float(self.videoHeaderView.playerView.duration())
        self.videoControlsView.timeLeft.text = self.convertPlayTimeToMinutes(seekToTime)
    }
    
    func sliderValueChanged(sliderValue value: Float) {
        // user let go of the panning tool, tell video to seek to right moment
        let seekToTime = value * Float(self.videoHeaderView.playerView.duration())
        self.videoHeaderView.seeking = true
        self.videoHeaderView.playerView.seekToSeconds(seekToTime, allowSeekAhead: true)
    }
    
    func doneSeeking() {
        userIsSeeking = false
    }
}