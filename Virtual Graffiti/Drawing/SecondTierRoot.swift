//
//  SecondTierRoot.swift
//  Login
//
//  Created by Spencer Grossarth on 3/6/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import SceneKit
import CoreLocation

class SecondTierRoot : LocationNode {
    var tileName = ""
    var QRValue = ""
    var uid = ""
    
    enum Keys: String {
        case location = "Location"
        case node = "node"
    }
    
    init() {
        let location = CLLocation()
        super.init(location: location)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
