//
//  DrawMode.swift
//  Login
//
//  Created by Stephen on 4/5/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation


class DrawState: State {
    var sceneView = SceneLocationView()
    
    var currentTile : String = ""
    
    var currentStroke : Stroke?
    
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var touchMovedCalled = false
    var lineBetweenNearFar : SCNVector3?
    var initialNearFarLine : SCNVector3?
    var userRootNode : SecondTierRoot?
    var distance : Float = 1
    let sphereRadius : CGFloat = 0.01
    var drawingColor: UIColor = .systemBlue
    
    func initialize(_sceneView: SceneLocationView!) {
        _initializeSceneView(_sceneView: _sceneView)
        initializeUserRootNode()
        load()
    }
    
    
    func initializeUserRootNode() {
        guard let location = sceneView.sceneLocationManager.currentLocation
            else { // No location, try again in a second
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: initializeUserRootNode)
                return
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let now = df.string(from: Date())

        userRootNode = SecondTierRoot(location: location)
        userRootNode?.name = "(\(location.coordinate.latitude), \(location.coordinate.longitude)), \(now)"
        sceneView.addLocationNodeForCurrentPosition(locationNode: userRootNode!)
    }
    
    
    override func enter() {
        // Do nothing
    }
    
    override func exit() {
        // sceneView.pause()
    }
    
    
    func _initializeSceneView(_sceneView: SceneLocationView!) {
        sceneView = _sceneView
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.run()
    }
    
    
    func createSphere(position : SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: sphereRadius)
        let material = SCNMaterial()
        material.diffuse.contents = self.drawingColor
        sphere.materials = [material]
        let node = SCNNode(geometry: sphere)
        node.position = position
        return node
    }
}


extension DrawState {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let rootNode = userRootNode, let singleTouch = touches.first {
            let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
            currentStroke = Stroke(firstPoint: touchLocation, color: drawingColor)
            rootNode.addChildNode(currentStroke!)
        } else {
            print("can't get touch")
        }
    }
     

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMovedCalled = true
        if let singleTouch = touches.first{
            let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
            guard let firstNearFarLine = initialNearFarLine else { return }
            guard let nearFar = lineBetweenNearFar else { return }
            currentStroke?.addVertices(point3D: touchLocation, initialNearFarLine: firstNearFarLine, lineBetweenNearFar: nearFar)
            currentStroke?.previousPoint = touchLocation
        } else {
            print("can't get touch")
        }
    }
     
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //Database().saveDrawing(location: location, userRootNode: userRootNode!)
        if !touchMovedCalled {
            if let rootNode = userRootNode, let singleTouch = touches.first{
                let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
                let sphereNode = createSphere(position: touchLocation)
                rootNode.addChildNode(sphereNode)
            } else {
                print("can't get touch")
            }
        }
        initialNearFarLine = nil
        touchMovedCalled = false
        save()
    }
    
    func touchLocationIn3D (touchLocation2D: CGPoint) -> SCNVector3 {
        let pointToUnprojectNear = SCNVector3(touchLocation2D.x, touchLocation2D.y, 0)
        let pointToUnprojectFar = SCNVector3(touchLocation2D.x, touchLocation2D.y, 1)
        let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
        let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
        var resizedVector = SCNVector3()
        if initialNearFarLine == nil {
            initialNearFarLine = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
            resizedVector  = resizeVector(vector: initialNearFarLine!, scalingFactor: distance)
        } else {
            lineBetweenNearFar = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
            resizedVector  = resizeVector(vector: lineBetweenNearFar!, scalingFactor: distance)
        }
        return SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
    }
}

//
//extension DrawState: ARSCNViewDelegate {
//
//}
//
//
//extension DrawState: ARSessionDelegate {
//    func session(_ session: ARSession, didUpdate frame: ARFrame) {
//         cameraTrans = frame.camera.transform * simd_float4(x: 1, y: 1, z: 1, w: 0)
//    }
//
//    func session(_ session: ARSession, didFailWithError error: Error) {
//        // Present an error message to the user
//    }
//
//    func sessionWasInterrupted(_ session: ARSession) {
//        // Inform the user that the session has been interrupted, for example, by presenting an overlay
//    }
//
//    func sessionInterruptionEnded(_ session: ARSession) {
//        // Reset tracking and/or remove existing anchors if consistent tracking is required
//    }
//}


extension DrawState {
    func save() {
        if let location = sceneView.sceneLocationManager.currentLocation, let rootNode = userRootNode {
            Database().saveDrawing(location: location, userRootNode: rootNode)
        }
    }
    

    func load() {
        let db = Database()

        guard let location = sceneView.sceneLocationManager.currentLocation
            else { // No location, try again in a second
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: load)
                return
        }

        currentTile = db.getTile(location: location)
        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
            // Reset scene
            self.sceneView.removeAllNodes()

            // Add nodes to view. Done asynchronously a VERY short time after the command to remove all nodes because removeAllNodes() will also remove the new nodes
            // 1 Millisecond delay still causes a flicker
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1), execute: {
                self.initializeUserRootNode()
                for node in retrievedNodes {
                    self.sceneView.addLocationNodeWithConfirmedLocation(locationNode: node)
                }
            })
        })
    }
}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}

