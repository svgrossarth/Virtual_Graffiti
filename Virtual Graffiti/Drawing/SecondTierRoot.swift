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
    var QRRelativeDistance = SCNVector3()
    
    enum Keys: String {
        case location = "Location"
        case node = "node"
    }
    
    init() {
        let location = CLLocation()
        super.init(location: location)
    }
    
    required init?(coder: NSCoder) {
        //let node = coder.decodeObject(forKey: Keys.node.rawValue) as! SCNNode
        super.init(coder: coder)

        //.fatalError("init(coder:) has not been implemented")
    }
}
