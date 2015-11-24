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

    @IBOutlet var addSongPressed: ProgressButton!
    
    /** true if ProgressButton is currently spinning */
    var spinning = false
    
    var song: [String: AnyObject]!
    var songManager: SongManager?
    
    func configureCell(song: [String: AnyObject]) {
        self.song = song
        
        let url = NSURL(string: self.song["albumarturl"] as! String)
        albumArt.sd_setImageWithURL(url)
        
        songArtist.text = self.song["songartist"] as? String
        songTitle.text = self.song["songname"] as? String
        
        (spinning ? addSongPressed.startSpinner() : addSongPressed.stopSpinner())
        
        if (songManager != nil) {
            addSongPressed.selected = (songManager?.songIDs.contains(song["songID"] as! String))!
        }
    }
    
    @IBAction func addSong(sender: AnyObject) {
        func success() {
            spinning = false
            addSongPressed.stopSpinner()
            addSongPressed.selected = true
        }
        func error() {
            spinning = false
            addSongPressed.stopSpinner()
            addSongPressed.selected = false
        }
        
        if !addSongPressed.selected {
            addSongPressed.startSpinner()
        }
        songManager?.addSong(self.song, success: success, error: error)
    }
}
