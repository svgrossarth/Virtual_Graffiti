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
    weak var sceneView: ARSCNView!
    
    let locationManager : CLLocationManager = CLLocationManager()
    var location : CLLocation = CLLocation()
    var currentTile : String = ""
    
    var currentStroke : Stroke?
    var hasAngleBeenSaved = false
    
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var touchMovedCalled = false
    var lineBetweenNearFar : SCNVector3?
    var initialNearFarLine : SCNVector3?
    var userRootNode : SecondTierRoot?
    var hasLocationBeenSaved =  false
    var heading : CLHeading = CLHeading()
    var headingSet : Bool = false
    
    
    func initialize(_sceneView: ARSCNView!) {
        _initializeLocationManager()
        _initializeSceneView(_sceneView: _sceneView)
    }
    
    
    override func enter() {
        // Do nothing
    }
    
    override func exit() {
        sceneView.session.pause()
    }
    
    
    func _initializeLocationManager() {
        location = CLLocation(latitude: -51, longitude: -51)
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    
    func _initializeSceneView(_sceneView: ARSCNView!) {
        sceneView = _sceneView
        addSubview(sceneView)
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        let configuration = ARWorldTrackingConfiguration() // Create a session configuration
        sceneView.session.run(configuration) // Run the view's session
    }
    
    
    func createSphere(position : SCNVector3) -> SCNNode {
        let sphere = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = PKCanvas().sendColor()
        sphere.materials = [material]
        let node = SCNNode(geometry: sphere)
        node.position = position
        return node
    }
}


extension DrawState {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let singleTouch = touches.first{
            let touchLocation = touchLocationIn3D(touch: singleTouch)
            currentStroke = Stroke(firstPoint: touchLocation)
            userRootNode?.addChildNode(currentStroke!)
        } else {
            print("can't get touch")
        }
    }
     

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMovedCalled = true
        if let singleTouch = touches.first{
            let touchLocation = touchLocationIn3D(touch: singleTouch)
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
            if let singleTouch = touches.first{
                let touchLocation = touchLocationIn3D(touch: singleTouch)
                let sphereNode = createSphere(position: touchLocation)
                userRootNode?.addChildNode(sphereNode)
            } else {
                print("can't get touch")
            }
        }
        initialNearFarLine = nil
        touchMovedCalled = false
    }
    
    func touchLocationIn3D (touch: UITouch) -> SCNVector3 {
        let touchLocation = touch.location(in: sceneView)
        let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
        let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
        let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
        let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
        var resizedVector = SCNVector3()
        if initialNearFarLine == nil {
            initialNearFarLine = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
            resizedVector  = resizeVector(vector: initialNearFarLine!, scalingFactor: 0.3)
        } else {
            lineBetweenNearFar = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
            resizedVector  = resizeVector(vector: lineBetweenNearFar!, scalingFactor: 0.3)
        }
        return SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
    }
}


extension DrawState: ARSCNViewDelegate {

}
    

extension DrawState: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
         cameraTrans = frame.camera.transform * simd_float4(x: 1, y: 1, z: 1, w: 0)
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


extension DrawState: CLLocationManagerDelegate {
    // Update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = manager.location {
            location = loc
            if(!hasLocationBeenSaved){
                hasLocationBeenSaved = true
                locationManager.startUpdatingHeading()
            }
            
            if hasAngleBeenSaved {
                if Database().getTile(location: loc) != currentTile {
//                    load()
                }
            }
        }
    }
    
    // Update header
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading
        headingSet = true
        let angle = deg2rad(heading.trueHeading)
        if !hasAngleBeenSaved {
            hasAngleBeenSaved = true
            
            let df = DateFormatter()
            df.dateFormat = "yyyy-MM-dd hh:mm:ss"
            let now = df.string(from: Date())
            userRootNode = SecondTierRoot(location: self.location, angleToNorth: angle)
            userRootNode?.name = String(location.coordinate.latitude) + String(location.coordinate.longitude) + now
            sceneView.scene.rootNode.addChildNode(userRootNode!)
           // load()
        }
        print("the angle", angle)
        
       // userRootNode?.rotate(by: SCNQuaternion(0, 1, 0, angle), aroundTarget: SCNVector3Make(0, 0, 0))
        //locationManager.stopUpdatingHeading()
    }
}


extension DrawState {
    //    func save() {
    //        Database().saveDrawing(location: location, userRootNode: userRootNode!)
    //    }
        
    
    //    func load() {
    //        if !headingSet {
    //            return
    //        }
    //
    //        let db = Database()
    //        currentTile = db.getTile(location: location)
    //        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
    //            for node in self.sceneView.scene.rootNode.childNodes {
    //                node.removeFromParentNode()
    //            }
    //
    //            for node in retrievedNodes {
    //                let lat1 = Float(self.location.coordinate.latitude) * Float.pi / 180.0
    //                let lat2 = Float(node.location.coordinate.latitude) * Float.pi / 180.0
    //                let dLat = lat2 - lat1
    //                let long1 = Float(self.location.coordinate.longitude) * Float.pi / 180.0
    //                let long2 = Float(node.location.coordinate.longitude) * Float.pi / 180.0
    //                let dLong = long2 - long1
    //                node.simdPosition = SIMD3<Float>(dLat, 0, dLong)
    //
    //                let currentAngle = deg2rad(self.heading.trueHeading)
    //                let angleOfRotation = currentAngle - node.angleToNorth
    //                node.rotate(by: SCNQuaternion(0, 1, 0, angleOfRotation), aroundTarget: SCNVector3Make(0, 0, 0))
    //
    //                self.sceneView.scene.rootNode.addChildNode(node)
    //            }
    //        })
    //
    //    }
}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
