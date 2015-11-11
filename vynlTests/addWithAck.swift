//
//  addWithAck.swift
//  vynl
//
//  Created by Eric Chen on 11/10/15.
//  Copyright © 2015 Eric Chen. All rights reserved.
//

import XCTest

class addWithAck: XCTestCase {
    
    var socketHelper: SocketHelper!
    
    override func setUp() {
        super.setUp()
        socketHelper.connect()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testAddWithAck() {
    }
    
}
