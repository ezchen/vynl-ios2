//
//  PartyViewController.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit

class PartyViewController: VynlDefaultViewController {

    @IBOutlet var videoView: UIView!
    var videoHeaderView: VideoHeaderView!
    @IBOutlet var partyCollectionView: UITableView!
    var currentlyPlaying: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //currentlyPlaying = true
        self.title = songManager.getPartyID()
        self.songManager.delegate = self
        
        self.videoHeaderView = NSBundle.mainBundle().loadNibNamed("VideoHeaderView", owner: self, options: nil)[0] as! VideoHeaderView
        self.videoHeaderView.songManager = self.songManager
        videoView.addSubview(videoHeaderView)
        
        
        if (songManager.songs.count == 0) {
            var view = NSBundle.mainBundle().loadNibNamed("EmptyPartyView", owner: self, options: nil)[0] as? UIView
            self.partyCollectionView.backgroundView = view
            self.partyCollectionView.separatorStyle = UITableViewCellSeparatorStyle.None
        } else {
            self.partyCollectionView.backgroundView = nil
            self.videoHeaderView.loadVideo()
            self.partyCollectionView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.partyCollectionView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
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
        if (segue.identifier == "search") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var viewController = navigationController.viewControllers[0] as! SearchViewController
            
            viewController.songManager = self.songManager
            viewController.delegate = self;
        }
    }
    

    @IBAction func backCalled(sender: AnyObject) {
        self.delegate?.dismissCalled()
    }
}

extension PartyViewController: DefaultModalDelegate {
    func dismissCalled() {
        self.dismissViewControllerAnimated(true, completion: nil)
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
    
}

extension PartyViewController: YTPlayerViewDelegate {
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch (state) {
            case YTPlayerState.Ended:
                break
            case YTPlayerState.Playing:
                break
            default:
                break
        }
    }
}

extension PartyViewController {
    func songManager(songsDidUpdate data: [String : AnyObject]) {
        print("SongManager's songs: ")
        print(songManager.songs)
        if (songManager.songs.count == 0) {
            var view = NSBundle.mainBundle().loadNibNamed("EmptyPartyView", owner: self, options: nil)[0] as? UIView
            self.partyCollectionView.backgroundView = view
            self.partyCollectionView.separatorStyle = UITableViewCellSeparatorStyle.None
        } else {
            self.partyCollectionView.backgroundView = nil;
            videoHeaderView.loadVideo()
            self.partyCollectionView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
            self.partyCollectionView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }
        self.partyCollectionView.reloadData()
    }
}