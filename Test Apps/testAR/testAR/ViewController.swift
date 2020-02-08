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
        //print("new touch")
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
            let material = UnlitMaterial(color: .green)
            //let material = SimpleMaterial(color: .green, isMetallic: false)
            //let entity = ModelEntity(mesh: MeshResource.generateSphere(radius: 0.01), materials: [material])
            let entity = ModelEntity(mesh: MeshResource.generateBox(width: 0.01, height: 0.01, depth: 0.01, cornerRadius: 1, splitFaces: false), materials: [material])
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
        //print("touch moved")
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
            guard let previousPoint = self.scene.findEntity(named: PREVIOUS_POINT) as? ModelEntity else {
                print("can't find previous point")
                return
            }
            let cloneEntity = previousPoint.clone(recursive: false)
//            let material = SimpleMaterial(color: .green, isMetallic: false)
//            let entity = ModelEntity(mesh: MeshResource.generateBox(width: 0.01, height: 0.01, depth: 0.01, cornerRadius: 1, splitFaces: false), materials: [material])
            //this is vital this realativeTo part is relative to the anchor at 0,0,o so the coordinates map properly
            cloneEntity.setPosition(pointIn3d, relativeTo: anchor)

            guard let worldOrigin = self.scene.findEntity(named: WORLD_ORIGIN) else {
                print("can't find world origin")
                return
            }

            self.generateMorePoints(currentPoint: cloneEntity, previousPoint: previousPoint, worldOrigin: worldOrigin)
            

            anchor.addChild(cloneEntity)
            previousPoint.name = ""
            //print("new previous point")
            cloneEntity.name = PREVIOUS_POINT
        } else {
            print("can't get touch")
        }
    }
    
    func generateMorePoints(currentPoint : ModelEntity, previousPoint : ModelEntity, worldOrigin : Entity){
        let currentPointPosition = currentPoint.position(relativeTo: worldOrigin)
        let previousPointPosition = previousPoint.position(relativeTo: worldOrigin)
        let distance = distanceBetweenPoints(currentPointPosition: currentPointPosition, previousPointPosition: previousPointPosition)
        if(distance > 0.005){
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
        //let lineBetweenPoints = currentPointPosition - previousPointPosition
        let newDistance = distance + 0.01
        let midPoint = simd_float3(x: (currentPointPosition.x + previousPointPosition.x)/2, y: (currentPointPosition.y + previousPointPosition.y)/2, z: ((currentPointPosition.z + previousPointPosition.z)/2))

        let material = UnlitMaterial(color: .green)
        //let material = SimpleMaterial(color: .green, isMetallic: false)
        //debugging
        //let connectingEntity = ModelEntity(mesh: MeshResource.generateBox(width: distance, height: 0.001, depth: 0.001, cornerRadius: 1, splitFaces: false), materials: [material])
        //normal
        let connectingEntity = ModelEntity(mesh: MeshResource.generateBox(width: newDistance, height: 0.01, depth: 0.01, cornerRadius: 1, splitFaces: false), materials: [material])
        connectingEntity.setPosition(midPoint, relativeTo: worldOrigin)
        connectingEntity.transform.rotation = findRotation(currentPointPosition: currentPointPosition, previousPointPosition: previousPointPosition, distance: distance)
        worldOrigin.addChild(connectingEntity)
       // print(worldOrigin.children.count)
        
        
        
        
        
        //let smallStep : Float = 0.001
       // let midPoint = simd_float3(x: (currentPointPosition.x - previousPointPosition.x)/2, y: (currentPointPosition.y - previousPointPosition.y)/2, z: ((currentPointPosition.z - previousPointPosition.z)/2)  - 0.3)
        //let num = Int(distance/smallStep)
        //print(num)

//        let ball = MeshResource.generateSphere(radius: 0.01)
        
//        for i in 1...num {
//            let clone = model.clone(recursive: false)
//            //let entity = ModelEntity(mesh: ball, materials: [material])
//            //let smallMove = lineBetweenPoints * (smallStep * Float(i))
//            let smallMove = lineBetweenPoints * (0.001 * Float(i))
//            clone.setPosition(smallMove, relativeTo: point)
//           // print(entity.position)
//            worldOrigin.addChild(clone)
//            print(worldOrigin.children.count)
//        }

        
    }
    
    func findRotation(currentPointPosition: simd_float3, previousPointPosition: simd_float3, distance : Float) -> simd_quatf{
        var oppositeSide = Float()
        var angle = Float()
//        if( currentPointPosition.y > previousPointPosition.y){
//            oppositeSide = currentPointPosition.y - previousPointPosition.y
//            angle = asin(oppositeSide/distance)
//        }else {
//            oppositeSide = previousPointPosition.y - currentPointPosition.y
//            //oppositeSide = previousPointPosition.x - currentPointPosition.x
//            angle = asin(oppositeSide/distance) + .pi/2
//
//            //angle = asin(oppositeSide/distance)
//        }
        
        //swipe upper right
        if(currentPointPosition.y > previousPointPosition.y && currentPointPosition.x > previousPointPosition.x){
            oppositeSide = currentPointPosition.y - previousPointPosition.y
            angle = asin(oppositeSide/distance)
           
        //swipe bottom left
        } else if (currentPointPosition.y < previousPointPosition.y && currentPointPosition.x < previousPointPosition.x){
            oppositeSide = previousPointPosition.y - currentPointPosition.y
            angle = asin(oppositeSide/distance) + .pi
        //swipe upper left
        } else if (currentPointPosition.y > previousPointPosition.y && currentPointPosition.x < previousPointPosition.x){
            oppositeSide = currentPointPosition.y - previousPointPosition.y
            angle = 2 * .pi -  asin(oppositeSide/distance)
        //swiper bottom right
        } else if (currentPointPosition.y < previousPointPosition.y && currentPointPosition.x > previousPointPosition.x){
            oppositeSide = previousPointPosition.y - currentPointPosition.y
            angle = 2 * .pi -  asin(oppositeSide/distance)
            //angle = asin(oppositeSide/distance)
            print("hi")
        }

        return simd_quatf(angle: angle, axis: simd_float3(x: 0, y: 0, z: 1))
    }
}
