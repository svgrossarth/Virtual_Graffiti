//
//  Emoji.swift
//  Login
//
//  Created by Scarlett Fan on 4/16/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation

class Emoji:Equatable {
    static func == (lhs: Emoji, rhs: Emoji) -> Bool {
        return lhs.name == rhs.name && lhs.ID == rhs.ID
    }

    let name : String
    let ID :  String

    init(name: String, ID: String) {
        self.name = name
        self.ID = ID
    }
}
