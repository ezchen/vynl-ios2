//
//  SocketHelper.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation
import Socket_IO_Client_Swift

protocol SocketHelperDelegate {
    func socketDidConnect(socketHelper socketHelper: SocketHelper!);
    func socketDidDisconnect(socketHelper socketHelper:SocketHelper!, disconnectedWithError error:NSError!)
    func socketHelper(socketHelper socketHelper: SocketHelper!, onError error: NSError!);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didReceiveMessage data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didReceiveJSON data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didSendMessage data: [String: AnyObject]);
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didConnect data: [String: AnyObject]);
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didMakeParty data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didGetID data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didNotifySongUpdate data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didUpdateSongs data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didStartPlayingSong data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, didJoin data: [String: AnyObject]);
    func socketHelper(socketHelper socketHelper: SocketHelper!, playSong data: [String: AnyObject]);
}

class SocketHelper: NSObject {
    var socket: SocketIOClient!;
    
    var socketHelperDelegate: SocketHelperDelegate!;
    var sessionID: String!;
}


extension SocketHelper {
    func connect() {
        let options: [String: AnyObject] = ["log": true]
        if (self.socket == nil) {
            self.socket = SocketIOClient(socketURL: Constants.SocketAPI.serverURL, opts: options)
            self.setupSocketListeners(socket);
        }
        socket.connect()
    }
    
    func connectWithID(id: String) {
        let options: [String: AnyObject] = ["nsp": "/party"]
        if (self.socket == nil) {
            self.socket = SocketIOClient(
                socketURL: Constants.SocketAPI.serverURL
                + String(Constants.SocketAPI.port),
                opts: options)
            self.setupSocketListeners(socket);
        }
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func getID() {
        print("socketHelper: gettingID from server")
        socket.emit(Constants.SocketAPI.getIDEventString, ["data": "success"])
    }
    
    func getIDWithExistingSessionWithString(sessionID: String) {
        socket.emit(Constants.SocketAPI.getIDEventString,
            ["data": "success",
            "sessionid": sessionID])
    }
    
    func leaveParty(partyID partyID: String) {
        socket.emit(Constants.SocketAPI.leavePartyEventString,
                    ["room": partyID])
    }
    
    func joinParty(partyID: String, sessionID: String) {
       socket.emit(Constants.SocketAPI.joinEventString,
                    ["room": partyID, "sessionid": sessionID])
    }
    
    func makeParty(partyID: String, sessionID: String) {
        print("socketHelper: make party called")
        socket.emit(Constants.SocketAPI.makePartyEventString,
                    ["room": partyID, "sessionid": sessionID])
    }
    
    func addSong(partyID partyID: String, song: [String: AnyObject]) {
        let data = ["room": partyID,
                    "song": song]
        socket.emit(Constants.SocketAPI.addSongEventString, data)
    }
    
    func addSongWithAck(partyID partyID: String, song: [String: AnyObject]) {
        let data = ["room": partyID,
                    "song": song]
        socket.emitWithAck(Constants.SocketAPI.addSongEventString, data)(timeoutAfter: 0) {data in
        }
    }
    
    func getSongs(partyID partyID: String, sessionID: String) {
        let data = ["room": partyID, "sessionid": sessionID]
        socket.emit(Constants.SocketAPI.getSongsEventString, data)
    }
    
    func voteOnSong(partyID partyID: String, song: [String: AnyObject], vote: Int, sessionID: String) {
        let data = ["room": partyID,
                    "song": song,
                    "vote": vote,
                    "sessionid": sessionID]
        socket.emit(Constants.SocketAPI.voteSongEventString, data)
    }
    
    func deleteSong(partyID partyID: String, song: [String: AnyObject], sessionID: String) {
        let data = ["room": partyID,
                    "song": song,
                    "sessionid": sessionID]
        socket.emit(Constants.SocketAPI.deleteSongEventString, data)
    }
    
    func playSong(partyID partyID: String, song: [String: AnyObject], sessionID: String) {
        let data = ["room": partyID,
                    "song": song,
                    "sessionid": sessionID]
        socket.emit("playSong", data)
    }
}

extension SocketHelper {
    /** Converts JSON Array [AnyObject] into Dictionary<String, AnyObject>
        returns an empty dictionary if there is no JSON data */
    private func initializeDictionary(data data: [AnyObject]) -> Dictionary<String, AnyObject> {
        var dict: Dictionary<String, AnyObject> = Dictionary<String, AnyObject>()
        if (data.count != 0) {
            dict = data[0] as! Dictionary
        }

        return dict
    }
    
    func setupSocketListeners(socket: SocketIOClient) {
        socket.on("connect") {data, ack in
            print("socketHelper: calling didConnect on socketHelperDelegate")
            
            // let dict = self.initializeDictionary(data: data)
            
            self.socketHelperDelegate.socketDidConnect(socketHelper: self);
        }
        
        socket.on("connected") {data, ack in
        }
        
        socket.on("getID") {data, ack in
            print("socketHelper: calling didGetID on socketHelperDelegate")
            
            let dict = self.initializeDictionary(data: data)
            
            self.sessionID = dict["id"] as! String
            
            self.socketHelperDelegate.socketHelper(socketHelper: self, didGetID: dict)
        }
        
        socket.on("makeParty") {data, ack in
            print("socketHelper: calling didMakeParty on socketHelperDelegate")
            
            let dict = self.initializeDictionary(data: data)
            
            if (dict["id"] != nil) {
                self.sessionID = dict["id"] as! String
            }
            
            self.socketHelperDelegate.socketHelper(socketHelper: self, didMakeParty: dict)
            print("finished make party method")
        }
        
        socket.on("join") {data, ack in
            print("socketHelper: calling didJoin on socketHelperDelegate")
            
            let dict = self.initializeDictionary(data: data)
            
            self.socketHelperDelegate.socketHelper(socketHelper: self, didJoin: dict)
        }
        
        socket.on("notifySongUpdate") {data, ack in
            print("socketHelper: calling notifySongUpdate on socketHelperDelegate")
            
            let dict = self.initializeDictionary(data: data)
            
            self.socketHelperDelegate.socketHelper(socketHelper: self, didNotifySongUpdate: dict)
        }
        
        socket.on("updateSongs") {data, ack in
            print("socketHelper: calling didUpdateSongs on socketHelperDelegate")
            
            let dict = self.initializeDictionary(data: data)
            
            self.socketHelperDelegate.socketHelper(socketHelper: self, didUpdateSongs: dict)
        }
        
        socket.on("playSong") {data, ack in
            print("socketHelper: calling playSong on socketHelperDelegate")
            
            let dict = self.initializeDictionary(data: data)
            
            self.socketHelperDelegate.socketHelper(socketHelper: self, didNotifySongUpdate: dict)
        }
    }
}