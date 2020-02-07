//
//  ViewController.swift
//  testAR
//
//  Created by Spencer Grossarth on 2/4/20.
//  Copyright © 2020 Spencer Grossarth. All rights reserved.
//

import UIKit
import RealityKit

let WORLD_ORIGIN : String = "worldOrigin"
let PREVIOUS_POINT : String = "perviousPoint"
let CURRENT_POINT : String = "currentPoint"

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //this anchor is at the origin world origin, it can be used a refence for other entities
        var worldOrigin = AnchorEntity(world: [0,0,0])
        worldOrigin.name = WORLD_ORIGIN
        self.arView.scene.addAnchor(worldOrigin)
        self.arView.frame = .zero
       // self.arView.debugOptions = [.showAnchorGeometry, .showAnchorOrigins, .showWorldOrigin]
        
    
    }
}


extension ARView {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("new touch")
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
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [material])
            //this is vital this realativeTo part is relative to the anchor at 0,0,o so the coordinates map properly
            entity.setPosition(pointIn3d, relativeTo: anchor)
            if let oldPreviousPoint = anchor.findEntity(named: PREVIOUS_POINT){
                oldPreviousPoint.name = ""
            }
            entity.name = PREVIOUS_POINT
            anchor.addChild(entity)
        } else {
            print("can't get touch")
        }
        
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?){
        print("touch moved")
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
            let material = SimpleMaterial(color: .green, isMetallic: false)
            let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [material])
            //this is vital this realativeTo part is relative to the anchor at 0,0,o so the coordinates map properly
            entity.setPosition(pointIn3d, relativeTo: anchor)
            guard let previousPoint = self.scene.findEntity(named: PREVIOUS_POINT) as? ModelEntity else {
                print("can't find previous point")
                return
            }
            guard let worldOrigin = self.scene.findEntity(named: WORLD_ORIGIN) else {
                print("can't find world origin")
                return
            }
            generateMorePoints(currentPoint: entity, previousPoint: previousPoint, worldOrigin: worldOrigin)
            anchor.addChild(entity)
            previousPoint.name = ""
            print("new previous point")
            entity.name = PREVIOUS_POINT
        } else {
            print("can't get touch")
        }
    }
    
    func generateMorePoints(currentPoint : ModelEntity, previousPoint : ModelEntity, worldOrigin : Entity){
        let currentPointPosition = currentPoint.position(relativeTo: worldOrigin)
        let previousPointPosition = previousPoint.position(relativeTo: worldOrigin)
        let distance = distanceBetweenPoints(currentPointPosition: currentPointPosition, previousPointPosition: previousPointPosition)
        if(distance > 0.001){
            renderPoints(currentPointPosition: currentPointPosition, previousPointPosition: previousPointPosition, point : previousPoint, worldOrigin : worldOrigin, distance: distance, model: currentPoint)
        }
    }
    
    func distanceBetweenPoints(currentPointPosition : simd_float3, previousPointPosition : simd_float3) -> Float {

        let xDist = (currentPointPosition.x - previousPointPosition.x)
        let yDist = (currentPointPosition.y - previousPointPosition.y)
        let zDist = (currentPointPosition.z - previousPointPosition.z)
        return sqrtf(pow(xDist, 2) + pow(yDist, 2) + pow(zDist, 2))
    }
    
    func renderPoints(currentPointPosition: simd_float3, previousPointPosition: simd_float3, point: Entity, worldOrigin : Entity, distance : Float, model : ModelEntity){
        let lineBetweenPoints = currentPointPosition - previousPointPosition
        let smallStep : Float = 0.001
       // let midPoint = simd_float3(x: (currentPointPosition.x - previousPointPosition.x)/2, y: (currentPointPosition.y - previousPointPosition.y)/2, z: ((currentPointPosition.z - previousPointPosition.z)/2)  - 0.3)
        let num = Int(distance/smallStep)
        //print(num)

//        let ball = MeshResource.generateSphere(radius: 0.01)
//        let material = SimpleMaterial(color: .green, isMetallic: false)
        for i in 1...num {
            let clone = model.clone(recursive: false)
            //let entity = ModelEntity(mesh: ball, materials: [material])
            //let smallMove = lineBetweenPoints * (smallStep * Float(i))
            let smallMove = lineBetweenPoints * (0.001 * Float(i))
            clone.setPosition(smallMove, relativeTo: point)
           // print(entity.position)
            worldOrigin.addChild(clone)
            print(worldOrigin.children.count)
        }

        
    }
}
