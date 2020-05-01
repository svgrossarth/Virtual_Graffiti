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
import Vision


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
    var touchMovedFirst = true
    var lineBetweenNearFar : SCNVector3?
    var initialNearFarLine : SCNVector3?
    var userRootNode = SecondTierRoot()
    var hasLocationBeenSaved =  false
    var heading : CLHeading = CLHeading()
    var headingSet : Bool = false
    var distance : Float = 1
    var width : Float = 0.01
    let sphereRadius : CGFloat = 0.01
    var drawingColor: UIColor = .systemBlue
    var isSingleTap = false
    
    var coordinate: CLLocation! = nil
    var frameCount = 0
    var newRootNode : SCNNode?
    var QRValue : String = ""
    var QRNodePosition = SCNVector3()
    var qrNode: QRNode? = nil
    var currentFrame : ARFrame?
    
    lazy var detectBarcodeRequest: VNDetectBarcodesRequest = {
        return VNDetectBarcodesRequest(completionHandler: { (request, error) in
            guard error == nil else {
                let alert = UIAlertController(title: "Barcode Error", message: error!.localizedDescription, preferredStyle: .alert)
                print("Error")
                return
            }

            self.processClassification(for: request)
        })
    }()
    
    func processClassification(for request: VNRequest) {
        // TODO: Extract payload
        DispatchQueue.main.async {
            if let bestResult = request.results?.first as? VNBarcodeObservation,
                let payload = bestResult.payloadStringValue {
                self.QRValue = payload
                
                var rect = bestResult.boundingBox
                
                // flips coordinates
                rect = rect.applying(CGAffineTransform(scaleX: 1, y: -1))
                rect = rect.applying(CGAffineTransform(translationX: 0, y: 1))
                
                // Get center
                let center = CGPoint(x: rect.midX, y: rect.midY)
                
                let sphere = SCNSphere(radius: self.sphereRadius)
                let material = SCNMaterial()
                material.diffuse.contents = self.drawingColor
                sphere.materials = [material]
                
                self.qrNode = QRNode(QRValue: self.QRValue, name: UUID().uuidString)
                self.qrNode!.geometry = sphere
                if let hitResult = self.currentFrame?.hitTest(center, types: .featurePoint).first {
                    //https://stackoverflow.com/questions/48980834/position-of-node-in-scene
                    let pointTransform = SCNMatrix4(hitResult.worldTransform) //turns the point into a point on the world grid
                    let pointVector = SCNVector3Make(pointTransform.m41, pointTransform.m42, pointTransform.m43) //the X, Y, and Z of the clicked coordinate
                    self.qrNode!.position = pointVector
                }
                
                
                self.userRootNode.removeFromParentNode()
                self.qrNode!.addChildNode(self.userRootNode)
                self.sceneView.scene.rootNode.addChildNode(self.qrNode!)
                self.userRootNode.worldPosition = SCNVector3(0,0,0)
                Database().saveQRNode(qrNode: self.qrNode!)
                Database().loadQRNode(qrNode: self.qrNode!, placeQRNodes: self.placeQRNodes)
            } else {
                //print("Cannot extract barcode information from data.")
            }
        }
    }
    
    func placeQRNodes(qrNodes : [QRNode]){
        for qrNode in qrNodes{
            self.sceneView.scene.rootNode.addChildNode(qrNode)
            if let localQRNode = self.qrNode {
                qrNode.position = localQRNode.position
                print("Place qr node")
                checkForDupUserRootNode(qrNode : qrNode)
            }
        }
    }
    
    func checkForDupUserRootNode(qrNode : QRNode){
        guard let qrNodeUserRoot = qrNode.childNodes.first else {
            print("can't get qr nodes user root node")
            return
        }
        for node in self.sceneView.scene.rootNode.childNodes {
            if let userRootNode = node as? SecondTierRoot{
                guard let userRootName = userRootNode.name else {
                    print("can't get userRootName")
                    return
                }
                guard let qrUserRootName = qrNodeUserRoot.name else {
                    print("can't get qrUserRootName")
                    return
                }
                if userRootName == qrUserRootName {
                    print("found duplicated userRootNode and removing, name of node is ", userRootName)
                    userRootNode.removeFromParentNode()
                }
            }
        }
    }
    
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
       // sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        let configuration = ARWorldTrackingConfiguration() // Create a session configuration
        sceneView.session.run(configuration) // Run the view's session
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
            userRootNode.light = addLighting()
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
                userRootNode.addChildNode(currentStroke!)
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
                userRootNode.addChildNode(sphereNode)
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


extension DrawState: ARSCNViewDelegate {

}
    

extension DrawState: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
         cameraTrans = frame.camera.transform * simd_float4(x: 1, y: 1, z: 1, w: 0)
        let distance = distanceBetweenPoints(vec1: SCNVector3(cameraTrans.x, cameraTrans.y, cameraTrans.z),
                                             vec2: SCNVector3(0, 0, 0))
        if distance > 20 {
            load()
        }

        frameCount += 1
        if QRValue == "" && frameCount == 100 {
            frameCount = 0
            let finalImage = CIImage(cvPixelBuffer: frame.capturedImage)
            
            // Perform the classification request on a background thread.
            DispatchQueue.global(qos: .userInitiated).async
            {
                let handler = VNImageRequestHandler(ciImage: finalImage, orientation: CGImagePropertyOrientation.up, options: [:])

                do
                {
                    self.currentFrame = frame
                    try handler.perform([self.detectBarcodeRequest])
                    
                } catch
                {
                    //self.showAlert(withTitle: "Error Decoding Barcode", message: error.localizedDescription)
                    print("error")
                }
            }
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
                    //load()
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

            userRootNode.location = self.location
            userRootNode.angleToNorth = angle
            userRootNode.tileName = Database().getTile(location: self.location)
            userRootNode.name = UUID().uuidString
            sceneView.scene.rootNode.addChildNode(userRootNode)
            load()
        }
        //print("the angle", angle)
        
       // userRootNode?.rotate(by: SCNQuaternion(0, 1, 0, angle), aroundTarget: SCNVector3Make(0, 0, 0))
        //locationManager.stopUpdatingHeading()
    }
}


extension DrawState {
    func save() {
        Database().saveDrawing(userRootNode: userRootNode)
        if let localQRNode = self.qrNode {
            Database().saveQRNode(qrNode: localQRNode)
        }
    }
    
    
    func load() {
        if !headingSet {
            return
        }
        let db = Database()
        currentTile = db.getTile(location: location)
        print("load has been called and herer is the tile", currentTile)
        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
            //            for node in self.sceneView.scene.rootNode.childNodes {
            //                node.removeFromParentNode()
            //            }
            
            for node in retrievedNodes {
                let nodeExists = self.checkIfNodeExists(newNode: node)
                if !nodeExists {
                    print("Node of Name will be added to scene ", node.name)
                    guard let nodeLocation = node.location else {
                        print("can't get node location")
                        return
                    }
                    let nodeLatitude = nodeLocation.coordinate.latitude
                    let nodeLongitude = nodeLocation.coordinate.longitude
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
                    //                print("Latitude difference: \(distanceWestToEastMeters)")
                    //                print("Longitude difference: \(distanceNorthToSouthMeters)")
                    
                    let currentAngle = deg2rad(self.heading.trueHeading)
                    let angleOfRotation = currentAngle - node.angleToNorth
                    node.rotation = SCNVector4Make(0, 1, 0, Float(angleOfRotation))
                    self.sceneView.scene.rootNode.addChildNode(node)
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
