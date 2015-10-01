//
//  VideoHeaderView.swift
//  vynl
//
//  Created by Eric Chen on 7/22/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import YouTubePlayer

protocol VideoHeaderViewDelegate {
    func didPlayTime(playTime: Float)
}

class VideoHeaderView: UIView {

    @IBOutlet var playerView: YTPlayerView!
    var songManager: SongManager!
    
    var state: YTPlayerState!
    
    var delegate: VideoHeaderViewDelegate!
    
    var newVideo = true
    var seeking = false
        
    var playerVars = ["controls": 0,
    "autoplay": 1,
    "showinfo": 0,
    "playsinline": 1,
    "modestbranding": 1,
    "origin": "http://vynl.party"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playerView.delegate = self
        state = YTPlayerState.Unknown
    }
}

extension VideoHeaderView {
    func loadVideo() {
        if (songManager.songs.count > 0) {
            if (state == YTPlayerState.Playing || state == YTPlayerState.Paused) {
                
            } else {
                self.playerView.loadWithVideoId(songManager.songs[0]["songID"] as! String, playerVars: playerVars)
            }
        }
    }
    
    func nextSong() {
        if (songManager.songs.count > 0) {
            loadNextVideo(songManager.songs[0]["songID"] as! String)
        }
    }
    
    func loadNextVideo(videoID: String) {
        self.newVideo = true
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
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        self.delegate.didPlayTime(playTime)
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        
        switch (state) {
            case YTPlayerState.Playing:
                print("videoHeaderView video is Playing")
                if (self.newVideo) {
                    // notify server that dj has started playing a new song
                    self.songManager.playSong()
                    self.newVideo = false
                }
                self.seeking = false
                break
            case YTPlayerState.Ended:
                if (self.songManager.songs.count > 0) {
                    self.newVideo = true
                    self.playerView.cueVideoById(self.songManager.songs[0]["songID"] as! String, startSeconds: 0, suggestedQuality: YTPlaybackQuality.Default)
                }
                print("ended")
                break
            case YTPlayerState.Paused:
                print("video is paused")
                break
            case YTPlayerState.Queued:
                print("video queued")
                self.playerView.playVideo()
                break
            default:
                print(state)
                break
        }
        
        self.state = state
    }
}