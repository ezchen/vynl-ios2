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
    
    var pausePressed = false
    var newVideo = true
    var seeking = false
    var autoplay = false
    
    /** Set to true when YTPlayerView calls playerViewDidBecomeReady */
    var playerViewIsReady = false
    
    /** list of videoID's that is loaded into YTPlayerView currently */
    var currentPlaylist: [String]?
        
    private var playerVars = ["controls": 0,
                              "autoplay": 1,
                              "showinfo": 0,
                              "playsinline": 1,
                              "modestbranding": 1,
                              "rel": 0,
                              "origin": "http://vynl.party"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.playerView.delegate = self
        state = YTPlayerState.Unknown
    }
}

extension VideoHeaderView {
    /** Should only be called once to load the YTPlayerView */
    func initYTPlayerViewWithVideo(videoId: String) {
        self.playerView.loadWithVideoId(videoId, playerVars: playerVars)
    }
    
    /** Loads videos from SongManager into ytPlayerView as a playlist.
        Should only be called when app is in foreground and between videos for
        continuous playback. */
    func loadVideos() {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            var songs = [String]()
            for song in songManager.songs {
                songs.append(song["songID"] as! String)
            }
            currentPlaylist = songs
            self.playerView.loadPlaylistByVideos(songs, index: 0, startSeconds: 0, suggestedQuality: YTPlaybackQuality.HD720)
        }
    }
    
    func loadVideo() {
        if (songManager.songs.count > 0) {
            if (state == YTPlayerState.Playing || pausePressed) {
                
            } else {
                if !playerViewIsReady {
                    self.playerView.loadWithVideoId(songManager.songs[0]["songID"] as! String, playerVars: playerVars)
                }
            }
        }
    }
    
    func nextSong() {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            self.newVideo = true
            loadVideos()
        } else if currentPlaylist!.count > 0 {
            loadNextVideo()
            play()
        } else if songManager.songs.count > 0 {
        }
    }
    
    func loadNextVideo() {
        self.newVideo = true
        self.playerView.nextVideo()
    }
    
    func pause() {
        // pause should not do anything if ytplayer isn't initialized yet
        if self.playerViewIsReady {
            self.playerView.pauseVideo()
            pausePressed = true
        }
    }
    
    func play() {
        // play should not do anything if ytplayer isn't initialized yet
        if self.playerViewIsReady {
            self.playerView.playVideo()
            pausePressed = false
            if self.state == YTPlayerState.Unknown || self.state == YTPlayerState.Ended {
                loadVideos()
            }
        }
    }
}

extension VideoHeaderView: YTPlayerViewDelegate {
    func playerView(playerView: YTPlayerView!, didPlayTime playTime: Float) {
        self.delegate.didPlayTime(playTime)
        
        // Video Ended
        if Int(playTime) == Int(playerView.duration()) {
            self.newVideo = true
            loadVideos()
        }
    }
    
    func playerView(playerView: YTPlayerView!, receivedError error: YTPlayerError) {
        print(error)
    }
    
    func playerViewDidBecomeReady(playerView: YTPlayerView!) {
        self.playerViewIsReady = true
        if (self.state == YTPlayerState.Ended && self.autoplay && self.songManager.songs.count > 0) {
            self.play()
        }
    }
    
    func playerView(playerView: YTPlayerView!, didChangeToState state: YTPlayerState) {
        
        switch (state) {
            case YTPlayerState.Playing:
                print("videoHeaderView video is Playing")
                if (self.newVideo && self.currentPlaylist?.count > 0) {
                    // notify server that dj has started playing a new song
                    if let songID = currentPlaylist?.removeAtIndex(0) {
                        self.songManager.playSong(["songID": songID])
                        self.newVideo = false
                    }
                }
                self.seeking = false
                break
            case YTPlayerState.Ended:
                // Playlist is over, not just the video
                self.newVideo = true
                if (self.songManager.songs.count > 0) {
                    loadVideos()
                    self.play()
                }
                print("ended")
                break
            case YTPlayerState.Paused:
                print("video is paused")
                if (!self.pausePressed) {
                    self.playerView.playVideo()
                }
                break
            case YTPlayerState.Queued:
                print("video queued")
                //self.playerView.playVideo()
                break
            case YTPlayerState.Buffering:
                print("video buffering")
                self.playerView.playVideo()
            default:
                print(state)
                break
        }
        
        self.state = state
    }
}