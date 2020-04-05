//
//  EditMode.swift
//  Login
//
//  Created by User on 4/5/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import PencilKit


class EditState: State {
    var pencilKitCanvas =  PKCanvas()
    
    
    func initialize() {
        updateCanvasOrientation(with: bounds)
        addPencilKit()
    }
    
    
    override func enter() {
        isHidden = false
    }
    
    
    override func exit() {
        isHidden = true
    }
}


extension EditState: PencilKitInterface, PencilKitDelegate {
    // Create a canvas view and make it a subview of ARSCNView so that the ToolPicker shows up and lets us change the color
    private func addPencilKit() {
        backgroundColor = .clear
        pencilKitCanvas  = createPencilKitCanvas(frame: frame, delegate: self)
        addSubview(pencilKitCanvas)
    }
}
