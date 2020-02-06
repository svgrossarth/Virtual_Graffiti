//
//  ViewController.swift
//  testAR
//
//  Created by Spencer Grossarth on 2/4/20.
//  Copyright © 2020 Spencer Grossarth. All rights reserved.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this anchor is at the origin world origin, it can be used a refence for other entities
        let anchor = AnchorEntity(world: [0,0,0])
        self.arView.scene.addAnchor(anchor)
        self.arView.frame = .zero
       // self.arView.debugOptions = [.showAnchorGeometry, .showAnchorOrigins, .showWorldOrigin]
    
    }
}


extension ARView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let singleTouch = touches.first{
            var touchLocation = singleTouch.location(in: self)
            var cameraTran = self.cameraTransform
            //this is important, or else the plan is off
            cameraTran.rotation = simd_quatf(angle: .pi/2 , axis: simd_float3(x: 1, y: 0, z: 0) )
            //puts the points in front of camera
            cameraTran.translation = SIMD3<Float>(cameraTran.translation.x, cameraTran.translation.y, cameraTran.translation.z - 0.3)
            
            guard let pointIn3d = self.unproject(touchLocation, ontoPlane: cameraTran.matrix) else {
                print("can't unproject")
                return
            }
            guard let anchor = self.scene.anchors.first else {
                print("cant get anchor")
                return
            }
            let material = SimpleMaterial(color: .green, isMetallic: true)
            let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [material])
            //this is vital this realativeTo part is relative to the anchor at 0,0,o so the coordinates map properly
            entity.setPosition(pointIn3d, relativeTo: anchor)
            anchor.addChild(entity)
        } else {
            print("can't get touch")
        }
        
    }
}
