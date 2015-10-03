//
//  SocketConstants.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation

struct Constants {
    struct SocketAPI {
        static let serverURL = "vynl.party";
        static let port = 8000;
        
        static let namespace = "/party";
        
        static let joinEventString = "join";
        static let getIDEventString = "getID";
        static let makePartyEventString = "makeParty";
        static let leavePartyEventString = "leave";
        static let addSongEventString = "addSong";
        static let getSongsEventString = "getSongs";
        static let voteSongEventString = "voteSong";
        static let deleteSongEventString = "deleteSong";
        static let playingSongEventString = "playingSong";
        
        static let notifySongUpdate = "notifySongUpdate";
        static let updateSongs = "updateSongs";
        static let error = "error";
        static let success = "success";
    }
}
