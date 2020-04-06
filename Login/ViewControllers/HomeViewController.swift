//
//  ViewController.swift
//  scenekittest
//
//  Created by Spencer Grossarth on 2/14/20.
//  Copyright © 2020 Spencer Grossarth. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import PencilKit
import CoreLocation


class HomeViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, PencilKitInterface, PencilKitDelegate, CLLocationManagerDelegate {
    let locationManager : CLLocationManager = CLLocationManager()
    var location : CLLocation = CLLocation()
    var currentStroke : Stroke?
    var hasAngleBeenSaved = false
    
    @IBOutlet weak var sceneView: ARSCNView!
    var pencilKitCanvas =  PKCanvas()
    
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var touchMovedCalled = false
    var lineBetweenNearFar = SCNVector3()

    var initialNearFarLine = SCNVector3()
    var userRootNode : SecondTierRoot?
    var hasLocationBeenSaved =  false
    var heading : CLHeading = CLHeading()
    var headingSet : Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addPencilKit()
        self.view.addSubview(sceneView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up location manager
        location = CLLocation(latitude: -51, longitude: -51)
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        let test = locationManager.location
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let singleTouch = touches.first{
            let touchLocation = singleTouch.location(in: sceneView)
            let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
            let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
            let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
            let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
            initialNearFarLine = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
            let resizedVector  = resizeVector(vector: initialNearFarLine, scalingFactor: 0.3)
            let nodePosition1 = SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
            currentStroke = Stroke(firstPoint: nodePosition1)
            userRootNode?.addChildNode(currentStroke!)
        } else {
            print("can't get touch")
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            touchMovedCalled = true
            if let singleTouch = touches.first{
                let touchLocation = singleTouch.location(in: sceneView)
                let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
                let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
                let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
                let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
                lineBetweenNearFar = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
                let resizedVector  = resizeVector(vector: lineBetweenNearFar, scalingFactor: 0.3)
                let nodePosition1 = SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
                
                currentStroke?.addVertices(point3D: nodePosition1, initialNearFarLine: initialNearFarLine, lineBetweenNearFar: lineBetweenNearFar)
                currentStroke?.previousPoint = nodePosition1
            } else {
                print("can't get touch")
            }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        Database().saveDrawing(location: location, userRootNode: userRootNode!)
    }
    
    
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
    
    
    

    /*
     Code below is used to create a canvas view and make it as a subview of our ARSCNView so that the ToolPicker will show up and left us change the color
     */
    
    private func addPencilKit() {
       view.backgroundColor = .clear
       pencilKitCanvas  = createPencilKitCanvas(frame: view.frame, delegate: self)
       view.addSubview(pencilKitCanvas)
    }
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          updateCanvasOrientation(with: view.bounds)
      }

    //MARK: - iOS override properties
    override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }

    override var prefersStatusBarHidden: Bool {
        return true;
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = manager.location {
            location = loc
            if(!hasLocationBeenSaved){
                hasLocationBeenSaved = true
                locationManager.startUpdatingHeading()
            }
        }
    }
    
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
    
    @IBAction func save(_ sender: Any) {
        print("hi")
    }
    func save() {
        Database().saveDrawing(location: location, userRootNode: userRootNode!)
    }
    
    func load() {
        if !headingSet {
            return
        }
        
        let db = Database()
        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
            for node in retrievedNodes {
                let lat1 = Float(self.location.coordinate.latitude) * Float.pi / 180.0
                let lat2 = Float(node.location.coordinate.latitude) * Float.pi / 180.0
                let dLat = lat2 - lat1
                let long1 = Float(self.location.coordinate.longitude) * Float.pi / 180.0
                let long2 = Float(node.location.coordinate.longitude) * Float.pi / 180.0
                let dLong = long2 - long1
                node.simdPosition = SIMD3<Float>(dLat, 0, dLong)
                
                let currentAngle = deg2rad(self.heading.trueHeading)
                let angleOfRotation = currentAngle - node.angleToNorth
                node.rotation = SCNVector4Make(0, 1, 0, Float(angleOfRotation))
                //node.rotate(by: SCNQuaternion(0, 1, 0, angleOfRotation), aroundTarget: SCNVector3Make(0, 0, 0))
                //print("current angle: ", currentAngle)
                //print("node angleToNorth: ", node.angleToNorth)
                //print("angle of rotation: ", angleOfRotation)
                //print("REEE, ", node.simdPosition)
                
                self.sceneView.scene.rootNode.addChildNode(node)
            }
        })
        
    }
    @IBAction func saveButton(_ sender: Any) {
        save()
    }
    @IBAction func loadButton(_ sender: Any) {
        load()
    }
}

// debug purposes
extension UIView {

    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
