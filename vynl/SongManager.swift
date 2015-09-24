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
    optional func songManager(didDisconnect data:[String: AnyObject])
    optional func songManager(didConnect data:[String: AnyObject])
    optional func songManager(onError data:[String: AnyObject])
}

class SongManager {
    var realm: Realm!
    var user: User!
    var socketHelper: SocketHelper!
    var isConnected: Bool!
    var isJoined: Bool!
    var delegate: SongManagerDelegate?
    var partyID: String!
    var songs: Array<[String: AnyObject]>!
    var dj: Bool!
    
    
    private func setUpSocketHelper() {
        
    }
    
    init() {
        do {
            try realm = Realm()
        
            let users = try Realm().objects(User)
            if (users.count == 0) {
                user = User()
            } else {
                user = try Realm().objects(User)[0]
            }
        
            try realm.write { () -> Void in
                self.realm.add(self.user, update: true)
            }
            
            setUpSocketHelper()
        } catch {
            print(error)
        }
        
        songs = []
        
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
    
    func playSong() {
        socketHelper.playSong(partyID: self.partyID, song: self.songs[0], sessionID: user.sessionid)
    }
    
    private func randomStringWithLength(length: Int) -> String {
        let alphabet = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let upperBound = UInt32(alphabet.characters.count)
        return String((0..<length).map { _ -> Character in
            return alphabet[alphabet.startIndex.advancedBy(Int(arc4random_uniform(upperBound)))]
            })
    }
}

// Mark: - SocketHelperDelegate
extension SongManager: SocketHelperDelegate {
    func socketDidConnect(socketHelper socketHelper: SocketHelper!) {
        self.isConnected = true
        self.delegate?.songManager!(didConnect: ["data": "connected"])
        
        if (user.sessionid.characters.count == 0) {
            socketHelper.getID()
        } else {
            socketHelper.getIDWithExistingSessionWithString(user.sessionid)
        }
    }
    
    func socketDidDisconnect(socketHelper socketHelper: SocketHelper!, disconnectedWithError error: NSError!) {
        self.isConnected = false
        self.isJoined = false
        self.delegate?.songManager!(didDisconnect: ["error": error])
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, onError error: NSError!) {
        self.delegate?.songManager!(onError: ["error": error])
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didReceiveMessage data: [String: AnyObject]) {
        
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didReceiveJSON data: [String: AnyObject]) {
        
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didSendMessage data: [String: AnyObject]) {
        
    }
    
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didConnect data: [String : AnyObject]) {
        
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didMakeParty data: [String : AnyObject]) {
        self.delegate?.songManager!(didMakeParty: data)
        self.socketHelper.joinParty(self.partyID, sessionID: self.user.sessionid)
        self.dj = true
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didGetID data: [String: AnyObject]) {
        let sessionid = data["id"] as! String;
        
        do {
        try realm.write { () -> Void in
            self.user.sessionid = sessionid
        }
        } catch {
            print(error)
        }
        print(self.user.sessionid)
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didNotifySongUpdate data: [String: AnyObject]) {
        self.socketHelper.getSongs(partyID: self.partyID, sessionID: self.user.sessionid)
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didUpdateSongs data: [String: AnyObject]) {
        self.songs = data["songs"] as! Array<[String: AnyObject]>
        self.delegate?.songManager!(songsDidUpdate: ["data": "songs"])
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didStartPlayingSong data: [String: AnyObject]) {
        
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, didJoin data: [String: AnyObject]) {
        self.isJoined = true
        self.songs = data["songs"] as! Array<[String: AnyObject]>
        self.dj = data["dj"] as! String == self.user.sessionid
        self.delegate?.songManager?(didJoin: data)
        self.delegate?.songManager?(songsDidUpdate: data)
    }
    
    func socketHelper(socketHelper socketHelper: SocketHelper!, playSong data: [String : AnyObject]) {
    }
    
}