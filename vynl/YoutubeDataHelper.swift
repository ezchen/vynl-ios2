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
            .responseJSON { _, _, JSON, _ in
                print(JSON)
                success(self.formatYoutubeJSON(JSON!))
        }
        println(request)
    }
    
    private func formatYoutubeJSON(json: AnyObject) -> [[String: AnyObject]] {
        var dict = json as! [String: AnyObject]
        var songs = dict["items"] as! [[String: AnyObject]]
        
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
        
        var title = snippet["title"] as! String
        var artist = snippet["channelTitle"] as! String
        
        var thumbnails = snippet["thumbnails"] as! [String: AnyObject]
        var defaultURL = thumbnails["default"] as! [String: AnyObject]
        var imageURL = defaultURL["url"] as! String
        
        var videoID = id["videoId"] as! String
        var upvotes = 0
        var downvotes = 0
        var upvoted = false
        var downvoted = false
        
        var song: [String: AnyObject] = [
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