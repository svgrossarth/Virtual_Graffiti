//
//  Emoji.swift
//  Login
//
//  Created by Scarlett Fan on 4/16/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation

class Emoji {
    let name : String
    let ID :  String
    var numSelected : Int

    init(name: String, ID: String) {
        self.name = name
        self.ID = ID
        numSelected = 1
    }

    func incrementNumSelected()  {
        numSelected += 1
    }
}
