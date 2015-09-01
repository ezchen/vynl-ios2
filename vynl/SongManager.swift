//
//  SongManager.swift
//  vynl
//
//  Created by Eric Chen on 7/14/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation
import RealmSwift

@objc protocol SongManagerDelegate {
    optional func songManager(didMakeParty data:[String: AnyObject])
    optional func songManager(songsDidUpdate data:[String: AnyObject])
    optional func songManager(didJoin data:[String: AnyObject])
}

class SongManager {
    let realm: Realm!
    var user: User!
    var socketHelper: SocketHelper!
    var isConnected: Bool!
    var isJoined: Bool!
    var delegate: SongManagerDelegate!
    var partyID: String!
    var songs: Array<[String: AnyObject]>!
    var dj: Bool!
    
    init() {
        realm = Realm()
        
        let users = Realm().objects(User)
        if (count(users) == 0) {
            user = User()
        } else {
            user = Realm().objects(User)[0]
        }
        
        realm.write { () -> Void in
            self.realm.add(self.user, update: true)
        }
        
        songs = []
        setUpSocketHelper()
    }
    
    private func setUpSocketHelper() {
        socketHelper = SocketHelper()
        socketHelper.socketHelperDelegate = self;
        socketHelper.connect()
    }
    
    func makeParty() {
        self.partyID = randomStringWithLength(8)
        socketHelper.makeParty(self.partyID, sessionID: user.sessionid)
    }
    
    func joinParty(partyID: String) {
        self.partyID = partyID
        socketHelper.joinParty(self.partyID, sessionID: user.sessionid)
    }
    
    func getPartyID() -> String {
        return self.partyID
    }
    
    func addSong(song: [String: AnyObject]) {
        socketHelper.addSong(partyID: self.partyID, song: song)
    }
    
    func vote(song: [String: AnyObject], vote: Int) {
        socketHelper.voteOnSong(partyID: self.partyID, song: song, vote: vote, sessionID: user.sessionid)
    }
    
    private func randomStringWithLength(length: Int) -> String {
        let alphabet = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(count(alphabet))
        return String((0..<length).map { _ -> Character in
            return alphabet[advance(alphabet.startIndex, Int(arc4random_uniform(upperBound)))]
            })
    }
}

// Mark: - SocketHelperDelegate
extension SongManager: SocketHelperDelegate {
    func socketDidConnect(#socketHelper: SocketHelper!) {
        self.isConnected = true
        
        if (count(user.sessionid) == 0) {
            socketHelper.getID()
        } else {
            socketHelper.getIDWithExistingSessionWithString(user.sessionid)
        }
    }
    
    func socketDidDisconnect(#socketHelper:SocketHelper!) {
        self.isConnected = false
        self.isJoined = false
    }
    
    func socketHelper(#socketHelper: SocketHelper!, onError error: NSError!) {
        
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didReceiveMessage data: [String: AnyObject]) {
        
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didReceiveJSON data: [String: AnyObject]) {
        
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didSendMessage data: [String: AnyObject]) {
        
    }
    
    
    func socketHelper(#socketHelper: SocketHelper!, didConnect data: [String : AnyObject]) {
        
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didMakeParty data: [String : AnyObject]) {
        self.delegate.songManager!(didMakeParty: data)
        self.socketHelper.joinParty(self.partyID, sessionID: self.user.sessionid)
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didGetID data: [String: AnyObject]) {
        var sessionid = data["id"] as! String;
        
        realm.write { () -> Void in
            self.user.sessionid = sessionid
        }
        println(self.user.sessionid)
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didNotifySongUpdate data: [String: AnyObject]) {
        self.socketHelper.getSongs(partyID: self.partyID, sessionID: self.user.sessionid)
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didUpdateSongs data: [String: AnyObject]) {
        self.songs = data["songs"] as! Array<[String: AnyObject]>
        self.delegate.songManager!(songsDidUpdate: ["data": "songs"])
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didStartPlayingSong data: [String: AnyObject]) {
        
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didJoin data: [String: AnyObject]) {
        self.isJoined = true
        self.songs = data["songs"] as! Array<[String: AnyObject]>
        self.dj = data["dj"] as! String == self.user.sessionid
        self.delegate.songManager?(didJoin: data)
        self.delegate.songManager?(songsDidUpdate: data)
    }
    
}