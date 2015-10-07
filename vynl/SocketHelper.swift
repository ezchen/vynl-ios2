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
    /* socket.io swift variables */
    var socket: SocketIOClient!;
    
    var socketIO: SocketIO!;
    var socketHelperDelegate: SocketHelperDelegate!;
    var sessionID: String!;
    
    /* connect to server */
    /*
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
*/
    
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
    func leaveParty(partyID partyID: String) {
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
    func addSong(partyID partyID: String, song: [String: AnyObject]) {
        let data = ["room": partyID,
            "song": song];
        socketIO.sendEvent(
            Constants.SocketAPI.addSongEventString,
            withData: data)
        
    }
    
    /* get all songs from current party room */
    func getSongs(partyID partyID: String, sessionID: String) {
        socketIO.sendEvent(
            Constants.SocketAPI.getSongsEventString,
            withData: ["room": partyID,
                    "sessionid": sessionID]);
    }
    
    /* vote on a song */
    func voteOnSong(partyID partyID: String, song: [String: AnyObject], vote: Int, sessionID: String) {
        let data = ["room": partyID,
            "song": song,
            "vote": vote,
            "sessionid": sessionID];
        socketIO.sendEvent(
            Constants.SocketAPI.voteSongEventString,
            withData: data);
    }
    
    /* delete a song */
    func deleteSong(partyID partyID: String, song: [String: AnyObject], sessionID: String) {
        let data = ["room": partyID,
            "song": song,
            "sessionid": sessionID];
        socketIO.sendEvent(
            Constants.SocketAPI.deleteSongEventString,
            withData: data);
    }
    
    func playSong(partyID partyID: String, song: [String: AnyObject], sessionID: String) {
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
        print("\n\n disconnectedWithError: ", error.code)
    }
    
    func socketIO(socket: SocketIO!, onError error: NSError!) {
        print("\n\n onError: ", error.code)
        socketHelperDelegate.socketHelper(socketHelper: self, onError: error)
    }
    
    func socketIO(socket: SocketIO!, didReceiveEvent packet: SocketIOPacket!) {
        /* filter through events and call proper method in delegate */
        print("received event with data %@", packet.dataAsJSON(), terminator: "");
        let dictionary: AnyObject! = packet.dataAsJSON();
        let name: String! = dictionary.objectForKey("name") as! String;
        let argsArray: NSArray! = dictionary.objectForKey("args") as! NSArray;
        let args: NSDictionary! = argsArray.objectAtIndex(0) as! NSDictionary;
        
        switch name {
        case "connect":
            print("socketHelper: calling didConnect on socketHelperDelegate")
            socketHelperDelegate.socketHelper(socketHelper: self, didConnect: args as! Dictionary)
            break
        case "getID":
            print("")
            print("socketHelper: calling didGetID on socketHelperDelegate")
            print("")
            self.sessionID = args.objectForKey("id") as! String
            print(socketHelperDelegate)
            socketHelperDelegate.socketHelper(socketHelper: self, didGetID: args as! Dictionary)
        case "makeParty":
            print("")
            print("socketHelper: calling didMakeParty on socketHelperDelegate")
            print("")
            if (args.objectForKey("id") != nil) {
                self.sessionID = args.objectForKey("id") as! String
            }
            socketHelperDelegate.socketHelper(socketHelper: self, didMakeParty: args as! Dictionary)
        case "join":
            print("")
            print("socketHelper: calling didJoin on socketHelperDelegate")
            print("")
            socketHelperDelegate.socketHelper(socketHelper: self, didJoin: args as! Dictionary)
        case "notifySongUpdate":
            print("")
            print("socketHelper: calling notifySongUpdate on socketHelperDelegate")
            print("")
            socketHelperDelegate.socketHelper(socketHelper: self, didNotifySongUpdate: args as! Dictionary)
        case "updateSongs":
            print("")
            print("socketHelper: calling didUpdateSongs on socketHelperDelegate")
            print("")
            socketHelperDelegate.socketHelper(socketHelper: self, didUpdateSongs: args as! Dictionary)
        case "playSong":
            print("")
            print("socketHelper: calling playSong on socketHelperDelegate")
            print("")
            socketHelperDelegate.socketHelper(socketHelper: self, playSong: args as! Dictionary)
        default:
            print("")
            print("socketHelper: default exhaustive used! MAKE EVENT HANDLER IN SWITCH CASE")
            print("")
            break
        }
        print(args)
    }
}

extension SocketHelper {
    func connect() {
        let options: [String: AnyObject] = ["log": true]
        if (self.socket == nil) {
            self.socket = SocketIOClient(socketURL: "localhost:8000", opts: options)
        }
        socket.connect()
    }
    
    func new_connectWithID(id: String) {
        let options: [String: AnyObject] = ["nsp": "/party"]
        if (self.socket == nil) {
            self.socket = SocketIOClient(
                socketURL: Constants.SocketAPI.serverURL
                + String(Constants.SocketAPI.port),
                opts: options)
        }
    }
    
    func new_disconnect() {
        socket.disconnect()
    }
    
    func new_getID() {
        socket.emit(Constants.SocketAPI.getIDEventString, ["data": "success", "sessionid": sessionID])
    }
    
    func new_getIDWithExistingSessionWithString(sessionID: String) {
        socket.emit(Constants.SocketAPI.getIDEventString,
            ["data": "success",
            "sessionid": sessionID])
    }
    
    func new_leaveParty(partyID partyID: String) {
        socket.emit(Constants.SocketAPI.leavePartyEventString,
                    ["room": partyID])
    }
    
    func new_joinParty(partyID: String, sessionID: String) {
       socket.emit(Constants.SocketAPI.makePartyEventString,
                    ["room": partyID, "sessionid": sessionID])
    }
    
    func new_makeParty(partyID: String, sessionID: String) {
        socket.emit(Constants.SocketAPI.makePartyEventString,
                    ["room": partyID, "sessionid": sessionID])
    }
    
    func new_addSong(partyID partyID: String, song: [String: AnyObject]) {
        let data = ["room": partyID,
                    "song": song]
        socket.emit(Constants.SocketAPI.addSongEventString, data)
    }
    
    func new_getSongs(partyID partyID: String, sessionID: String) {
        let data = ["room": partyID, "sessionid": sessionID]
        socket.emit(Constants.SocketAPI.getSongsEventString, data)
    }
    
    func new_voteOnSong(partyID partyID: String, song: [String: AnyObject], vote: Int, sessionID: String) {
        let data = ["room": partyID,
                    "song": song,
                    "vote": vote,
                    "sessionid": sessionID]
        socket.emit(Constants.SocketAPI.voteSongEventString, data)
    }
    
    func new_deleteSong(partyID partyID: String, song: [String: AnyObject], sessionID: String) {
        let data = ["room": partyID,
                    "song": song,
                    "sessionid": sessionID]
        socket.emit(Constants.SocketAPI.deleteSongEventString, data)
    }
}

extension SocketHelper {
    func setupSocketListeners(socket: SocketIOClient) {
        socket.on("connect") {data, ack in
            self.socketHelperDelegate.socketHelper(socketHelper: self, didConnect: data[0] as! Dictionary)
        }
    }
}