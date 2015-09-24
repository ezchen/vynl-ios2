//
//  UISearchTableViewCell.swift
//  vynl
//
//  Created by Eric Chen on 7/27/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

class UISearchTableViewCell: UITableViewCell {
    @IBOutlet var albumArt: UIImageView!
    @IBOutlet var songArtist: UILabel!
    @IBOutlet var songTitle: UILabel!

    @IBOutlet var addSongPressed: UIButton!
    
    var song: [String: AnyObject]!
    var songManager: SongManager?
    
    func configureCell(song: [String: AnyObject]) {
        self.song = song
        
        let url = NSURL(string: self.song["albumarturl"] as! String)
        albumArt.sd_setImageWithURL(url)
        
        songArtist.text = self.song["songartist"] as? String
        songTitle.text = self.song["songname"] as? String
    }
    
    @IBAction func addSong(sender: AnyObject) {
        songManager?.addSong(self.song)
    }
}
