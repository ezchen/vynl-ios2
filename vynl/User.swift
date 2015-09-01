//
//  User.swift
//  vynl
//
//  Created by Eric Chen on 7/14/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation
import RealmSwift

class User: Object {
    dynamic var sessionid = ""
    dynamic var session = 0
    
    override static func primaryKey() -> String? {
        return "session"
    }
}