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
    weak var sceneView: SceneLocationView!
    
    var currentTile : String = ""
    // Startup Buffer because the initial locationmanager locations are not the most accurate
    let startupBufferLimit = 3
    var startupBuffer = 0
    
    var currentStroke : Stroke?
    
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var touchMovedFirst = true
    var lineBetweenNearFar : SCNVector3?
    var initialNearFarLine : SCNVector3?
    var userRootNode : SecondTierRoot?
    var hasLocationBeenSaved =  false
    var heading : CLHeading = CLHeading()
    var headingSet : Bool = false
    var distance : Float = 1
    var width : Float = 0.01
    let sphereRadius : CGFloat = 0.01
    var drawingColor: UIColor = .systemBlue
    var isSingleTap = false
    
    func initialize(_sceneView: SceneLocationView!) {
        _initializeSceneView(_sceneView: _sceneView)
        initializeUserRootNode()
    }
    
    
    override func enter() {
        // Do nothing
    }
    
    override func exit() {
        // sceneView.session.pause()
    }
    
    
    func initializeUserRootNode() {
        guard let location = sceneLocationManager.currentLocation else {
            // No location, try again in a second
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: initializeUserRootNode)
            return
        }
        
        let df = DateFormatter()
        df.dateFormat = "yyy-MM-dd hh:mm:ss"
        let now = df.string(from: Date())
        
        userRootNode = SecondTierRoot(location: location)
        userRootNode?.name = "(\(location.coordinate.latitude), \(location.coordinate.longitude)), \(now)"
        userRootNode?.tileName = Database().getTile(location: location)
        print("Initialized at tile \(Database().getTile(location: location))")
        sceneView.addLocationNodeForCurrentPosition(locationNode: userRootNode!)
        
        load()
    }
    
    
    func _initializeSceneView(_sceneView: SceneLocationView!) {
        sceneView = _sceneView
        addSubview(sceneView)
       // sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.run() // Run the view's session
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
        isSingleTap = true
        if let singleTouch = touches.first{
            userRootNode?.light = addLighting()
        } else {
            print("can't get touch")
        }
    }
     func addLighting() ->SCNLight{
            let light = SCNLight()
            light.type = SCNLight.LightType.ambient
            light.color = UIColor.white
            return light
        }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let singleTouch = touches.first{
            let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
            if touchMovedFirst {
                touchMovedFirst =  false
                currentStroke = Stroke(firstPoint: touchLocation, color: drawingColor, thickness : width)
                userRootNode?.addChildNode(currentStroke!)
            } else {
                guard let firstNearFarLine = initialNearFarLine else { return }
                guard let nearFar = lineBetweenNearFar else { return }
                currentStroke?.addVertices(point3D: touchLocation, initialNearFarLine: firstNearFarLine, lineBetweenNearFar: nearFar)
                currentStroke?.previousPoint = touchLocation
            }
        } else {
            print("can't get touch")
        }
    }
     
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touchMovedFirst && isSingleTap {
            if let singleTouch = touches.first{
                let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
                let sphereNode = createSphere(position: touchLocation)
                userRootNode?.addChildNode(sphereNode)
            } else {
                print("can't get touch")
            }
        }
        isSingleTap = false
        touchMovedFirst = true
        initialNearFarLine = nil
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


extension DrawState: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
         cameraTrans = frame.camera.transform * simd_float4(x: 1, y: 1, z: 1, w: 0)
        let distance = distanceBetweenPoints(vec1: SCNVector3(cameraTrans.x, cameraTrans.y, cameraTrans.z),
                                             vec2: SCNVector3(0, 0, 0))
        if distance > 20 {
            load()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
}


extension DrawState {
    func save() {
        guard let location = sceneLocationManager.currentLocation, let rootNode = userRootNode else { return }
        Database().saveDrawing(location: location, userRootNode: rootNode)
    }
    
    
    func load() {
        guard let location = sceneLocationManager.currentLocation else { return }
        let db = Database()
        currentTile = db.getTile(location: location)
        print("load has been called and here is the tile", currentTile)
        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
            //self.sceneView.removeAllNodes() // Clear nodes
            
            for node in retrievedNodes {
                let nodeExists = self.checkIfNodeExists(newNode: node)
                if !nodeExists {
                    self.sceneView.addLocationNodeWithConfirmedLocation(locationNode: node)
                    if let nodeLocation = node.location {
                        print("Node at location: \(nodeLocation)")
                    }
                }
            }
        })
    }
    
    func checkIfNodeExists(newNode : SecondTierRoot) -> Bool {
        let listOfCurrentNodes = sceneView.scene.rootNode.childNodes
        for childNode in listOfCurrentNodes {
            if childNode.name == newNode.name{
                return true
            }
        }
        return false
    }
}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
