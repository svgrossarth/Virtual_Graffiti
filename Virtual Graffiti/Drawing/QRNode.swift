//
//  QRNode.swift
//  Login
//
//  Created by Elvis Alvarado on 4/30/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import SceneKit

class QRNode : SCNNode {
    var QRValue = ""
    var uid = ""
    var tileName = ""
    
    init(QRValue: String, name: String) {
        super.init()
        self.QRValue = QRValue
        self.name = name
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
