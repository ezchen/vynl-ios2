//
//  VideoHeaderView.swift
//  vynl
//
//  Created by Eric Chen on 7/22/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import YouTubePlayer

class VideoHeaderView: UIView {

    @IBOutlet var playerView: YTPlayerView!
    var songManager: SongManager!
        
    var playerVars = ["controls": 0,
    "autoplay": 1,
    "showinfo": 0,
    "playsinline": 1,
    "modestbranding": 1,
    "origin": "http://vynl.party"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playerView.delegate = self
    }
}

extension VideoHeaderView {
    func loadVideo() {
        if (songManager.songs.count > 0) {
            self.playerView.loadWithVideoId(songManager.songs[0]["songID"] as! String, playerVars: playerVars)
        }
    }
    
    func loadNextVideo(videoID: String) {
        self.playerView.cueVideoById(videoID, startSeconds: 0, suggestedQuality: YTPlaybackQuality.Default)
    }
    
    func pause() {
        self.playerView.pauseVideo()
    }
    
    func play() {
        self.playerView.playVideo()
    }
}

extension VideoHeaderView: YTPlayerViewDelegate {
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        switch (state) {
            case YTPlayerState.Playing:
                break
            case YTPlayerState.Ended:
                self.playerView.cueVideoById(self.songManager.songs[0]["songID"] as! String, startSeconds: 0, suggestedQuality: YTPlaybackQuality.Default)
                println("ended")
                break
            case YTPlayerState.Paused:
                break
            default:
                break
        }
    }
}