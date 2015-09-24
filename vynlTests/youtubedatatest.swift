//
//  youtubedata.swift
//  vynl
//
//  Created by Eric Chen on 7/25/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import XCTest

class youtubedatatest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSearch() {
        var datahelper = YoutubeDataHelper()
        var expectation = expectationWithDescription("makeParty")
        print("hello")
        func success(json: AnyObject) {
            print(json)
            expectation.fulfill()
            XCTAssertNotNil(json, "search worked!")
        }
        datahelper.search("taylor swift", pageToken: nil, resultsPerPage: 5, success: success)
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }

}
