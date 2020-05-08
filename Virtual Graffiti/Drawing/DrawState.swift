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


class DrawState: State, ARSCNViewDelegate {
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
    var userRootNode : SecondTierRoot = SecondTierRoot()
    var hasLocationBeenSaved =  false
    var heading : CLHeading = CLHeading()
    var headingSet : Bool = false
    var distance : Float = 1
    var width : Float = 0.01
    let sphereRadius : CGFloat = 0.01
    var drawingColor: UIColor = .systemBlue
    var currentPen = "bluePen"
    
    var coordinate: CLLocation! = nil
    var frameCount = 0
    var newRootNode : SCNNode?
    var QRValue : String = ""
    var QRNodePosition = SCNVector3()
    var qrNode: QRNode? = nil
    var currentFrame : ARFrame?
    var userUID = ""
    var tileName = ""
    var dataBase = Database()
    
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
                if self.tileName != "" {
                    self.qrNode?.tileName = self.tileName
                }
                self.qrNode!.geometry = sphere
                if let hitResult = self.currentFrame?.hitTest(center, types: .featurePoint).first {
                    //https://stackoverflow.com/questions/48980834/position-of-node-in-scene
                    let pointTransform = SCNMatrix4(hitResult.worldTransform) //turns the point into a point on the world grid
                    let pointVector = SCNVector3Make(pointTransform.m41, pointTransform.m42, pointTransform.m43) //the X, Y, and Z of the clicked coordinate
                    self.qrNode!.position = pointVector
                }
                
                
                self.userRootNode.removeFromParentNode()
                self.qrNode!.addChildNode(self.userRootNode)
                self.qrNode!.uid = self.userUID
                guard let sceneNode = self.sceneView.sceneNode else {
                    print("ERROR: sceneNode not available to place qrNode, this is a problem with the new ARCL library")
                    return
                }
                sceneNode.addChildNode(self.qrNode!)
                self.userRootNode.worldPosition = SCNVector3(0,0,0)
                self.dataBase.saveQRNode(qrNode: self.qrNode!)
                self.dataBase.loadQRNode(qrNode: self.qrNode!, placeQRNodes: self.placeQRNodes)
            } else {
                //print("Cannot extract barcode information from data.")
            }
        }
    }
    
    
    func placeQRNodes(qrNodes : [QRNode]){
        print("calling place qr nodes")
        for qrNode in qrNodes{
            var duplicateQRNode = false
            guard let qrNodeUserRoot = qrNode.childNodes.first else {
                print("can't get qr nodes user root node")
                return
            }
            guard let sceneNode = self.sceneView.sceneNode else {
                print("ERROR: sceneNode not available to view its children, this is a problem with the new ARCL library")
                return
            }
            for node in sceneNode.childNodes {
                if let userRootNode = node as? SecondTierRoot{
                    guard let userRootName = userRootNode.name else {
                        print("can't get userRootName")
                        return
                    }
                    guard let qrUserRootName = qrNodeUserRoot.name else {
                        print("can't get qrUserRootName")
                        return
                    }
                    //print("checkForDupUserRootNode: Checking if user root node with name: ", userRootName, "matches any qr user root nodes")
                    if userRootName == qrUserRootName {
                        //print("checkForDupUserRootNode: found duplicated userRootNode and removing, name of node is ", userRootName)
                        userRootNode.removeFromParentNode()
                    }
                } else if let childQRNode = node as? QRNode {
                    if qrNode.name == childQRNode.name && childQRNode.name != self.qrNode?.name {
                        qrNode.position = childQRNode.position
                        childQRNode.removeFromParentNode()
                        sceneNode.addChildNode(qrNode)
                        duplicateQRNode = true
                    } else if qrNode.name == childQRNode.name && childQRNode.name == self.qrNode?.name {
                        duplicateQRNode = true
                    }
                }
            }
            if !duplicateQRNode{
                if let localQRNode = self.qrNode {
                    qrNode.position = localQRNode.position
                    sceneNode.addChildNode(qrNode)
                }
            }
        }
    }
    
    
    func initialize(_sceneView: SceneLocationView!, userUID: String) {
        self.userUID = userUID
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
        
        userRootNode = SecondTierRoot()
        userRootNode.name = UUID().uuidString
        self.tileName = self.dataBase.getTile(location: location)
        userRootNode.tileName = self.tileName
        if qrNode != nil {
            qrNode?.tileName = self.tileName
        }
        //print("Initialized at tile \(Database().getTile(location: location))")
        sceneView.addLocationNodeForCurrentPosition(locationNode: userRootNode)
        userRootNode.uid = userUID

        if let sceneNode = self.sceneView.sceneNode{
            sceneNode.light = addLighting()
        }
        
        load()
    }
    
    
    func _initializeSceneView(_sceneView: SceneLocationView!) {
        sceneView = _sceneView
        addSubview(sceneView)
       // sceneView.showsStatistics = true
        let scene = SCNScene()
        sceneView.scene = scene
        
        sceneView.run() // Run the view's session
        
         sceneView.arViewDelegate = self
         sceneView.session.delegate = self
        // sceneView.showsStatistics = true
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


     func addLighting() ->SCNLight{
                let estimate: ARLightEstimate!
                let light = SCNLight()

                estimate = self.sceneView.session.currentFrame?.lightEstimate
                light.intensity = estimate.ambientIntensity*0.5
                light.castsShadow = false
                light.type = SCNLight.LightType.directional
                light.categoryBitMask = 1
               
                return light
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let singleTouch = touches.first{
            let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
            if touchMovedFirst {
                touchMovedFirst =  false
                currentStroke = Stroke(firstPoint: touchLocation, color: drawingColor, thickness : width)
                currentStroke?.categoryBitMask = ~1
                userRootNode.addChildNode(currentStroke!)
            } else {
                guard let firstNearFarLine = initialNearFarLine else { return }
                guard let nearFar = lineBetweenNearFar else { return }
                currentStroke?.categoryBitMask = ~1
                currentStroke?.addVertices(point3D: touchLocation, initialNearFarLine: firstNearFarLine, lineBetweenNearFar: nearFar)
                currentStroke?.previousPoint = touchLocation
            }
        } else {
            print("can't get touch")
        }
    }
     
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchMovedFirst = true
        initialNearFarLine = nil
        save()
    }
    
    func placeSingleTapBall(touches: Set<UITouch>){
        if let singleTouch = touches.first{
            let touchLocation = touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
            let sphereNode = createSphere(position: touchLocation)
            sphereNode.geometry?.firstMaterial?.lightingModel = SCNMaterial.LightingModel.constant;
            sphereNode.categoryBitMask = ~1
            userRootNode.addChildNode(sphereNode)
        }
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


extension DrawState {
    func save() {
        if let localQRNode = self.qrNode {
            print("save in drawstate saving qr node")
            self.dataBase.saveQRNode(qrNode: localQRNode)
        }
        guard let location = sceneLocationManager.currentLocation else { return }
        self.dataBase.saveDrawing(userRootNode: userRootNode)
    }
    
    
    func load() {
        guard let location = sceneLocationManager.currentLocation else { return }
        self.dataBase = Database()
        currentTile = dataBase.getTile(location: location)
        print("load has been called and here is the tile", currentTile)
        dataBase.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
            //self.sceneView.removeAllNodes() // Clear nodes
            for node in retrievedNodes {
                //print("drawFunction: node going to placed in scene with name: ", node.name)
                self.checkAndPlaceUserRootNode(newNode: node)
            }
        })
    }
    
    func checkAndPlaceUserRootNode(newNode : SecondTierRoot) {
        var duplicateUserRootNode = false
        guard let sceneNode = self.sceneView.sceneNode else {
            print("ERROR: sceneNode not available to view its children, this is a problem with the new ARCL library")
            return
        }
        let listOfCurrentNodes = sceneNode.childNodes
        for childNode in listOfCurrentNodes {
            if let qrNode = childNode as? QRNode {
                if let innerUserNode = qrNode.childNodes.first {
                    if innerUserNode.name == newNode.name{
                        duplicateUserRootNode = true
                    }
                }
            } else if let userNode = childNode as? SecondTierRoot {
                if userNode.name == newNode.name && userNode.name != self.userRootNode.name{
                    duplicateUserRootNode = true
                    userNode.removeFromParentNode()
                    self.sceneView.addLocationNodeWithConfirmedLocation(locationNode: newNode)
                } else if userNode.name == newNode.name && userNode.name == self.userRootNode.name{
                    duplicateUserRootNode = true
                }
            }
            
            
        }
        if !duplicateUserRootNode{
            self.sceneView.addLocationNodeWithConfirmedLocation(locationNode: newNode)
        }
    }
}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
