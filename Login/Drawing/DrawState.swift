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
    // Startup Buffer because the initial locationmanager locations are not the most accurate
    let startupBufferLimit = 3
    var startupBuffer = 0
    
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
    var distance : Float = 1
    let sphereRadius : CGFloat = 0.01
    
    
    func initialize(_sceneView: ARSCNView!) {
        _initializeLocationManager()
        _initializeSceneView(_sceneView: _sceneView)
    }
    
    
    override func enter() {
        // Do nothing
    }
    
    override func exit() {
        // sceneView.session.pause()
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
        let sphere = SCNSphere(radius: sphereRadius)
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
            let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
            currentStroke = Stroke(firstPoint: touchLocation)
            userRootNode?.addChildNode(currentStroke!)
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
        if !touchMovedCalled {
            if let singleTouch = touches.first{
                let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
                let sphereNode = createSphere(position: touchLocation)
                userRootNode?.addChildNode(sphereNode)
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
        if (startupBuffer < startupBufferLimit) {
            startupBuffer += 1
            return
        }
        
        if let loc = manager.location {
            location = loc
            if(!hasLocationBeenSaved){
                hasLocationBeenSaved = true
                locationManager.startUpdatingHeading()
            }
            
            if hasAngleBeenSaved {
                if Database().getTile(location: loc) != currentTile {
                    load()
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
            load()
        }
        //print("the angle", angle)
        
       // userRootNode?.rotate(by: SCNQuaternion(0, 1, 0, angle), aroundTarget: SCNVector3Make(0, 0, 0))
        //locationManager.stopUpdatingHeading()
    }
}


extension DrawState {
    func save() {
        if let rootNode = userRootNode {
            Database().saveDrawing(location: location, userRootNode: rootNode)
        }
    }
    

    func load() {
        if !headingSet {
            return
        }

        let db = Database()
        currentTile = db.getTile(location: location)
        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
//            for node in self.sceneView.scene.rootNode.childNodes {
//                node.removeFromParentNode()
//            }

            for node in retrievedNodes {
                let nodeLatitude = node.location.coordinate.latitude
                let nodeLongitude = node.location.coordinate.longitude
                let phoneLatitude = self.location.coordinate.latitude
                let phoneLongitude = self.location.coordinate.longitude
                var distanceWestToEastMeters = Float(self.location.distance(from: CLLocation.init(latitude: nodeLatitude, longitude: phoneLongitude)))
                var distanceNorthToSouthMeters = Float(self.location.distance(from: CLLocation.init(latitude: phoneLatitude, longitude: nodeLongitude)))
                
                if (nodeLatitude < phoneLatitude) {
                    distanceWestToEastMeters *= -1
                }
                if (nodeLongitude < phoneLongitude) {
                    distanceNorthToSouthMeters *= -1
                }
                
                node.simdPosition = SIMD3<Float>(distanceWestToEastMeters, 0.0, distanceNorthToSouthMeters)
                print("Latitude difference: \(distanceWestToEastMeters)")
                print("Longitude difference: \(distanceNorthToSouthMeters)")

                let currentAngle = deg2rad(self.heading.trueHeading)
                let angleOfRotation = currentAngle - node.angleToNorth
                node.rotation = SCNVector4Make(0, 1, 0, Float(angleOfRotation))

                self.sceneView.scene.rootNode.addChildNode(node)
            }
        })

    }
}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
