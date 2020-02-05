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
        
        let material = SimpleMaterial(color: .green, isMetallic: true)
        let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [material])
        //let model = ModelEntity(mesh: MeshResource.generateSphere(radius: 10))
        //let anchor = AnchorEntity(plane: .horizontal)
        //        anchor.addChild(entity)
        //anchor.addChild(entity)
        //self.arView.scene.addAnchor(anchor)
        self.arView.frame = .zero
        self.arView.debugOptions = [.showAnchorGeometry, .showAnchorOrigins, .showWorldOrigin]
        
        // Load the "Box" scene from the "Experience" Reality File
//        let boxAnchor = try! Experience.loadBox()
//
//        // Add the box anchor to the scene
//        arView.scene.anchors.append(boxAnchor)
    }
}


extension ARView {
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
 //       print("touching began")
        if let singleTouch = touches.first{
           // if let anchor  = self.scene.anchors.first{
                
                var touchLocation = singleTouch.location(in: self)
            
                var cameraTran = self.cameraTransform
                cameraTran.rotation = simd_quatf(angle: .pi/2 , axis: simd_float3(x: 1, y: 0, z: 0) )
            
                //cameraTran.translation = SIMD3<Float>(cameraTran.translation.x, cameraTran.translation.y, cameraTran.translation.z * 0.1)
                cameraTran.translation = SIMD3<Float>(cameraTran.translation.x, cameraTran.translation.y, cameraTran.translation.z - 0.3)

                guard let pointIn3d = self.unproject(touchLocation, ontoPlane: cameraTran.matrix) else {
                    print("can't unproject")
                    return
                }
//            if(self.scene.anchors.count == 0){
//                self.scene.addAnchor(AnchorEntity.init(world: cameraTran.matrix) )
//            }
//            guard let anchor = self.scene.anchors.first else {
//                print("cant get anchor")
//                return
//            }
                
                let material = SimpleMaterial(color: .green, isMetallic: true)
                let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [material])
             //   entity.setPosition(pointIn3d, relativeTo: self.scene)
               // print(pointIn3d)
                //entity.position = pointIn3d
                //let plane = ModelEntity(mesh: MeshResource.generatePlane(width: 0.1, height: 0.1), materials: [material])
            //plane.position = pointIn3d
              //  print(cameraTran.matrix)
            //anchor.addChild(plane)
                let anchor2 = AnchorEntity(world: pointIn3d)
                anchor2.addChild(entity)
                //anchor2.addChild(plane)
                self.scene.addAnchor(anchor2)
                //anchor.addChild(entity)
                //anchor.addChild(plane)
                
         //   }
        } else {
            print("can't get touch")
        }
        
    }
}
