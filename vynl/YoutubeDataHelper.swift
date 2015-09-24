//
//  YoutubeDataHelper.swift
//  vynl
//
//  Created by Eric Chen on 7/25/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation
import Alamofire

class YoutubeDataHelper {
    private let YOUTUBE_API_URL = "https://www.googleapis.com/youtube/v3/search"
    private let YOUTUBE_API_SEARCH = "search"
    private let YOUTUBE_API_KEY = "AIzaSyDScuK6YCvbLjjBSg4TfsZtnzK47GZXc5I"
    
    
    func search(query: String, pageToken: String?, resultsPerPage: UInt, success: (AnyObject) -> ()) {
        
        var params = ["part": "snippet", "q": query, "type": "video", "maxResults": String(resultsPerPage), "key": YOUTUBE_API_KEY]
        
        if (pageToken != nil) {
            
        }
        let request = Alamofire.request(.GET, YOUTUBE_API_URL, parameters: params)
            .validate()
            .responseJSON { _, _, JSON in
                print(JSON, terminator: "")
                success(self.formatYoutubeJSON(JSON.value!))
        }
        print(request)
    }
    
    private func formatYoutubeJSON(json: AnyObject) -> [[String: AnyObject]] {
        var dict = json as! [String: AnyObject]
        let songs = dict["items"] as! [[String: AnyObject]]
        
        var formattedSongs = [[String: AnyObject]]()
        for song in songs {
            formattedSongs.append(self.formatSong(song));
        }
        return formattedSongs
    }
    
    /* format to vynl song json
     * {songname: "songname",
     *  songartist: "songartist",
     *  albumarturl: "albumarturl",
     *  songID: "videoID",
     *  upvotes: 0,
     *  downvotes: 0,
     *  upvoted: false,
     *  downvoted: false}
     */
    private func formatSong(json: AnyObject) -> [String: AnyObject] {
        var dict = json as! [String: AnyObject]
        var snippet = dict["snippet"] as! [String: AnyObject]
        var id = dict["id"] as! [String: AnyObject]
        
        let title = snippet["title"] as! String
        let artist = snippet["channelTitle"] as! String
        
        var thumbnails = snippet["thumbnails"] as! [String: AnyObject]
        var defaultURL = thumbnails["default"] as! [String: AnyObject]
        let imageURL = defaultURL["url"] as! String
        
        let videoID = id["videoId"] as! String
        let upvotes = 0
        let downvotes = 0
        let upvoted = false
        let downvoted = false
        
        let song: [String: AnyObject] = [
            "songname": title,
            "songartist": artist,
            "albumarturl": imageURL,
            "songID": videoID,
            "upvotes": upvotes,
            "downvotes": downvotes,
            "upvoted": upvoted,
            "downvoted": downvoted
        ]
        
        return song
    }
}