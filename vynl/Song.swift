//
//  Song.swift
//  vynl
//
//  Created by Eric Chen on 7/27/15.
//  Copyright (c) 2015 Eric Chen. All rights reserved.
//

import Foundation
import RealmSwift

/*
 * Not used yet... Delete this comment if you use it
 */
class Song: Object {
    dynamic var name = ""
    dynamic var artist = ""
    dynamic var imageURL = ""
    dynamic var upVotes = 0
    dynamic var downVotes = 0
}