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
    
    init(QRValue: String, name: String) {
        super.init()
        self.QRValue = QRValue
        self.name = name
    }
    
    required init?(coder: NSCoder) {
        //let node = coder.decodeObject(forKey: Keys.node.rawValue) as! SCNNode
        super.init(coder: coder)
        //.fatalError("init(coder:) has not been implemented")
    }
}
