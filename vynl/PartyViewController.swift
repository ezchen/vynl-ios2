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
        
        /* Only Show Video View if User is DJ */
        if (self.songManager.dj!) {
            self.videoHeaderView = NSBundle.mainBundle().loadNibNamed("VideoHeaderView", owner: self, options: nil)[0] as! VideoHeaderView
            self.videoHeaderView.songManager = self.songManager
            videoView.addSubview(videoHeaderView)
        } else {
            videoView.hidden = true
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
        if (segue.identifier == "search") {
            var navigationController = segue.destinationViewController as! UINavigationController
            var viewController = navigationController.viewControllers[0] as! SearchViewController
            
            viewController.songManager = self.songManager
            self.songManager.delegate = nil;
            viewController.delegate = self;
        }
    }
    
    @IBAction func backCalled(sender: AnyObject) {
        self.delegate?.dismissCalled()
    }
    
    func toggleEmptyView(isEmpty: Bool) {
        if (isEmpty) {
            var view = NSBundle.mainBundle().loadNibNamed("EmptyPartyView", owner: self, options: nil)[0] as? UIView
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
}

extension PartyViewController: DefaultModalDelegate {
    /* perform actions after dismissing modals
     * 
     * search modal is dismissed */
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
    
}

extension PartyViewController {
    func songManager(songsDidUpdate data: [String : AnyObject]) {
        print("SongManager's songs: ")
        print(songManager.songs)
        self.toggleEmptyView(songManager.songs.count == 0)
        self.partyCollectionView.reloadData()
    }
    
    override func songManager(didConnect data: [String : AnyObject]) {
        /* super class creates toast message */
        super.songManager(didConnect: data)
        
        /* rejoin the party */
        self.songManager.joinParty(songManager.partyID)
    }
}