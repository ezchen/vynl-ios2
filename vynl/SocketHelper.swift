//
//  SocketHelper.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation

protocol SocketHelperDelegate {
    func socketDidConnect(#socketHelper: SocketHelper!);
    func socketDidDisconnect(#socketHelper:SocketHelper!, disconnectedWithError error:NSError!)
    func socketHelper(#socketHelper: SocketHelper!, onError error: NSError!);
    func socketHelper(#socketHelper: SocketHelper!, didReceiveMessage data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didReceiveJSON data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didSendMessage data: [String: AnyObject]);
    
    func socketHelper(#socketHelper: SocketHelper!, didConnect data: [String: AnyObject]);
    
    func socketHelper(#socketHelper: SocketHelper!, didMakeParty data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didGetID data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didNotifySongUpdate data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didUpdateSongs data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didStartPlayingSong data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, didJoin data: [String: AnyObject]);
    func socketHelper(#socketHelper: SocketHelper!, playSong data: [String: AnyObject]);
}

class SocketHelper: NSObject {
    
    var socketIO: SocketIO!;
    var socketHelperDelegate: SocketHelperDelegate!;
    var sessionID: String!;
    
    /* connect to server */
    func connect() {
        if (self.socketIO == nil) {
            self.socketIO = SocketIO(delegate: self);
        }
        
        socketIO.connectToHost(
            Constants.SocketAPI.serverURL,
            onPort: Constants.SocketAPI.port,
            withParams: nil,
            withNamespace: Constants.SocketAPI.namespace);
    }
    
    func connectWithID(id: String) {
        if (self.socketIO == nil) {
            self.socketIO = SocketIO(delegate: self);
        }
        self.sessionID = id
        
        socketIO.connectToHost(
            Constants.SocketAPI.serverURL,
            onPort: Constants.SocketAPI.port,
            withParams: ["sessionid": id],
            withNamespace: Constants.SocketAPI.namespace);
    }
    
    /* disconnect from server */
    func disconnect() {
        socketIO.disconnect();
    }
    
    func getID() {
        socketIO.sendEvent(
            Constants.SocketAPI.getIDEventString,
            withData: ["data": "success"]);
    }
    
    func getIDWithExistingSessionWithString(sessionID: String) {
        socketIO.sendEvent(
            Constants.SocketAPI.getIDEventString,
            withData: ["data": "success",
                    "sessionid": sessionID])
    }
    
    /* leave party room (unsubscribe from notifications) */
    func leaveParty(#partyID: String) {
        socketIO.sendEvent(
            Constants.SocketAPI.leavePartyEventString,
            withData: ["room": partyID]);
    }
    
    /* join party room (subscribe to notifications) */
    func joinParty(partyID: String, sessionID: String) {
       socketIO.sendEvent(
        Constants.SocketAPI.joinEventString,
        withData: ["room": partyID,
                    "sessionid": sessionID]);
    }
    
    /* make a party room */
    func makeParty(partyID: String, sessionID: String) {
        socketIO.sendEvent(
            Constants.SocketAPI.makePartyEventString,
            withData: ["room": partyID,
                    "sessionid": sessionID]);
    }
    
    /* add a song to current party room */
    func addSong(#partyID: String, song: [String: AnyObject]) {
        var data = ["room": partyID,
            "song": song];
        socketIO.sendEvent(
            Constants.SocketAPI.addSongEventString,
            withData: data)
        
    }
    
    /* get all songs from current party room */
    func getSongs(#partyID: String, sessionID: String) {
        socketIO.sendEvent(
            Constants.SocketAPI.getSongsEventString,
            withData: ["room": partyID,
                    "sessionid": sessionID]);
    }
    
    /* vote on a song */
    func voteOnSong(#partyID: String, song: [String: AnyObject], vote: Int, sessionID: String) {
        var data = ["room": partyID,
            "song": song,
            "vote": vote,
            "sessionid": sessionID];
        socketIO.sendEvent(
            Constants.SocketAPI.voteSongEventString,
            withData: data);
    }
    
    /* delete a song */
    func deleteSong(#partyID: String, song: [String: AnyObject]) {
        var data = ["room": partyID,
            "song": song];
        socketIO.sendEvent(
            Constants.SocketAPI.deleteSongEventString,
            withData: data);
    }
    
    func playSong(#partyID: String, song: [String: AnyObject], sessionID: String) {
        socketIO.sendEvent("playSong", withData: ["room": partyID,
                                                "song": song,
                                                "sessionid": sessionID])
    }
    
    /* not sure yet */
    func playingSong() {
        
    }
}

extension SocketHelper: SocketIODelegate {
    func socketIODidConnect(socket: SocketIO!) {
        socketHelperDelegate.socketDidConnect(socketHelper: self);
    }
    
    func socketIODidDisconnect(socket: SocketIO!, disconnectedWithError error: NSError!) {
        socketHelperDelegate.socketDidDisconnect(socketHelper: self, disconnectedWithError: error)
        println("\n\n disconnectedWithError: ", error.code)
    }
    
    func socketIO(socket: SocketIO!, onError error: NSError!) {
        println("\n\n onError: ", error.code)
        socketHelperDelegate.socketHelper(socketHelper: self, onError: error)
    }
    
    func socketIO(socket: SocketIO!, didReceiveEvent packet: SocketIOPacket!) {
        /* filter through events and call proper method in delegate */
        print("received event with data %@", packet.dataAsJSON());
        var dictionary: AnyObject! = packet.dataAsJSON();
        var name: String! = dictionary.objectForKey("name") as! String;
        var argsArray: NSArray! = dictionary.objectForKey("args") as! NSArray;
        var args: NSDictionary! = argsArray.objectAtIndex(0) as! NSDictionary;
        
        switch name {
        case "connect":
            println("socketHelper: calling didConnect on socketHelperDelegate")
            socketHelperDelegate.socketHelper(socketHelper: self, didConnect: args as! Dictionary)
            break
        case "getID":
            println()
            println("socketHelper: calling didGetID on socketHelperDelegate")
            println()
            self.sessionID = args.objectForKey("id") as! String
            println(socketHelperDelegate)
            socketHelperDelegate.socketHelper(socketHelper: self, didGetID: args as! Dictionary)
        case "makeParty":
            println()
            println("socketHelper: calling didMakeParty on socketHelperDelegate")
            println()
            self.sessionID = args.objectForKey("id") as! String
            socketHelperDelegate.socketHelper(socketHelper: self, didMakeParty: args as! Dictionary)
        case "join":
            println()
            println("socketHelper: calling didJoin on socketHelperDelegate")
            println()
            socketHelperDelegate.socketHelper(socketHelper: self, didJoin: args as! Dictionary)
        case "notifySongUpdate":
            println()
            println("socketHelper: calling notifySongUpdate on socketHelperDelegate")
            println()
            socketHelperDelegate.socketHelper(socketHelper: self, didNotifySongUpdate: args as! Dictionary)
        case "updateSongs":
            println()
            println("socketHelper: calling didUpdateSongs on socketHelperDelegate")
            println()
            socketHelperDelegate.socketHelper(socketHelper: self, didUpdateSongs: args as! Dictionary)
        case "playSong":
            println()
            println("socketHelper: calling playSong on socketHelperDelegate")
            println()
            socketHelperDelegate.socketHelper(socketHelper: self, playSong: args as! Dictionary)
        default:
            println()
            println("socketHelper: default exhaustive used! MAKE EVENT HANDLER IN SWITCH CASE")
            println()
            break
        }
        println(args)
    }
}