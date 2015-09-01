//
//  UIPartyCollectionViewCell.swift
//  vynl
//
//  Created by Eric Chen on 7/24/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import UIKit

class UIPartyCollectionViewCell: UITableViewCell {
    
    @IBOutlet var albumImage: UIImageView!
    @IBOutlet var songName: UILabel!
    @IBOutlet var artistName: UILabel!
    @IBOutlet var songLength: UILabel!
    @IBOutlet var numVotes: UILabel!
    @IBOutlet var downVoteButton: UIButton!
    @IBOutlet var upVoteButton: UIButton!
    
    
    
    var songManager: SongManager!
    var song: [String: AnyObject]!
    
    func configureCell(song: [String: AnyObject]) {
        self.song = song
        
        var url = NSURL(string: self.song["albumarturl"] as! String)
        albumImage.sd_setImageWithURL(url)
        
        self.songName.text = self.song["songname"] as? String
        
        self.artistName.text = self.song["songartist"] as? String
        
        var numUpVotes = self.song["upvotes"] as? Int
        var numDownVotes = self.song["downvotes"] as? Int
        var numVotesInt = numUpVotes! - numDownVotes!
        self.numVotes.text = String(format: "%li votes", numVotesInt)
        
        self.downVoteButton.selected = (self.song["downvoted"] as? Int == 1)
        self.upVoteButton.selected = (self.song["upvoted"] as? Int == 1)
    }
    
    @IBAction func downVote(sender: AnyObject) {
        songManager?.vote(song, vote: -1)
    }
    
    @IBAction func upVote(sender: AnyObject) {
        songManager?.vote(song, vote: 1)
    }
}
