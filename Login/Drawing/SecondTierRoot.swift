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
    //var angleToNorth : Double = 0
    
    enum Keys: String {
      case location = "Location"
      case node = "node"
    }
    
    init(location : CLLocation) {
        super.init(location: location)
        //self.angleToNorth = angleToNorth
    }
    
    required init?(coder: NSCoder) {
        //self.location = CLLocation()
        //let node = coder.decodeObject(forKey: Keys.node.rawValue) as! SCNNode
        super.init(coder: coder)

        //.fatalError("init(coder:) has not been implemented")
    }
}
