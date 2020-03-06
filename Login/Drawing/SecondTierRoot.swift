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

class SecondTierRoot : SCNNode{
    var location : CLLocation
    
    init(location : CLLocation) {
        self.location = location
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
