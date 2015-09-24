//
//  SocketHelperTest.swift
//  vynl
//
//  Created by Eric Chen on 7/11/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import XCTest

class SocketHelperTest: XCTestCase {
    
    var socketHelper: SocketHelper!
    var testingConnectAssertion = false;
    var testingDisconnectAssertion = false;
    var testingEventAssertion = false;
    
    var testingDidGetID = false;
    var testingDidGetIDWithExistingSession = false;
    var testingMakeParty = false;
    var testingDidNotifySongUpdate = false;
    var testingGetSongs = false;
    var testingVoteSongs = false;
    var testingUpdateSongs = false;
    var testingAddSong = false;
    var testingDidStartPlayingSong = false;
    var testingJoin = false;
    
    var expectation: XCTestExpectation!
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        testingConnectAssertion = false;
        testingDisconnectAssertion = false;
        testingEventAssertion = false;
       
        testingDidGetID = false;
        testingDidGetIDWithExistingSession = false;
        testingMakeParty = false;
        testingDidNotifySongUpdate = false;
        testingGetSongs = false;
        testingVoteSongs = false;
        testingUpdateSongs = false;
        testingAddSong = false;
        testingDidStartPlayingSong = false;
        testingJoin = false;
        
        socketHelper = SocketHelper();
        socketHelper.socketHelperDelegate = self;
        socketHelper.connect();
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
   
    func testDiconnect() {
        self.testingDisconnectAssertion = true;
        socketHelper.disconnect()
    }
    
    func testDidGetID() {
        self.testingDidGetID = true
        socketHelper.getID()
        self.expectation = expectationWithDescription("didGetID");
        self.waitForExpectationsWithTimeout(1.0, handler: nil)
    }
    
    func testDidGetIDWithExistingSession() {
        self.testingDidGetIDWithExistingSession = true;
        var sessionID = "ASDF"
        socketHelper.getIDWithExistingSessionWithString(sessionID)
        self.expectation = expectationWithDescription("didGetIDWIthExistingSession")
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testMakeParty() {
        self.testingMakeParty = true;
        socketHelper.makeParty("TESTTEST", sessionID: "ASDF")
        self.expectation = expectationWithDescription("makeParty")
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testJoin() {
        self.testingJoin = true
        socketHelper.joinParty("TESTTEST", sessionID: "ASDF")
        self.expectation = expectationWithDescription("makeParty")
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testAddSong() {
        self.testingAddSong = true
        socketHelper.joinParty("TESTTEST", sessionID: "ASDF")
        self.expectation = expectationWithDescription("makeParty")
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testGetSong() {
        self.testingGetSongs = true
        socketHelper.joinParty("TESTTEST", sessionID: "ASDF")
        socketHelper.getSongs(partyID: "TESTTEST", sessionID: "ASDF")
        self.expectation = expectationWithDescription("GETSONGS")
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func testVoteSong() {
        self.testingVoteSongs = true
        socketHelper.joinParty("TESTTEST", sessionID: "ASDF")
        socketHelper.voteOnSong(partyID: "TESTTEST", song: ["songID": "testID"], vote: 1, sessionID: "ASDF")
    }
}

extension SocketHelperTest: SocketHelperDelegate {
    func socketDidConnect(#socketHelper: SocketHelper!) {
    }
    
    func socketDidDisconnect(#socketHelper: SocketHelper!, disconnectedWithError error: NSError!) {
        if (self.testingDisconnectAssertion) {
            XCTAssert(true, "socket disconnected")
            self.expectation.fulfill()
        }
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
        print(data)
        if (self.testingConnectAssertion) {
            XCTAssert(self.socketHelper.sessionID != nil, "socket connected")
            self.expectation.fulfill()
        }
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didGetID data: [String: AnyObject]) {
        if (self.testingDidGetID) {
            self.expectation.fulfill()
            var sessionID = data["id"] as! String;
            XCTAssertNotNil(socketHelper.sessionID, "socketHelper.sessionID is not nil")
            XCTAssertNotNil(sessionID, "sessionID is not nil")
        } else if (self.testingDidGetIDWithExistingSession) {
            self.expectation.fulfill()
            var sessionID = data["id"] as! String;
            XCTAssertEqual(sessionID, "ASDF", "sessionID is equal to initial session: ASDF")
        }
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didMakeParty data: [String : AnyObject]) {
        if (self.testingMakeParty) {
            self.expectation.fulfill()
            var sessionID = data["id"] as! String
            XCTAssertNotNil(sessionID, "didMakeParty: sessionID is not nil")
        }
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didNotifySongUpdate data: [String: AnyObject]) {
        if (self.testingAddSong) {
            self.expectation.fulfill()
            XCTAssert(true, "didNotifySongUpdate: add Song notified")
        }
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didUpdateSongs data: [String: AnyObject]) {
        if (self.testingUpdateSongs) {
            self.expectation.fulfill()
            XCTAssert(true, "songs updated")
        } else if (self.testingGetSongs) {
            self.expectation.fulfill()
            XCTAssert(true, "get songs called")
        } else if (self.testingVoteSongs) {
            self.expectation.fulfill()
            XCTAssertTrue(true, "vote songs called")
        }
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didStartPlayingSong data: [String: AnyObject]) {
        
    }
    
    func socketHelper(#socketHelper: SocketHelper!, didJoin data: [String: AnyObject]) {
        if (self.testingJoin) {
            self.expectation.fulfill()
            var songs: NSArray = data["songs"] as! NSArray
            var djID = data["dj"] as! String
            XCTAssertNotNil(songs, "didJoin songs not nil")
            XCTAssertNotNil(djID, "didJoin djID not nil")
        }
        if (self.testingAddSong) {
            var song = ["songID": "testID", "albumarturl": "testArtURL", "songname": "testSongName", "songartist": "testSongArtist"]
            socketHelper.addSong(partyID: "TESTTEST", song: song)
        }
    }
    
    func socketHelper(#socketHelper: SocketHelper!, playSong data: [String : AnyObject]) {
    }
}
