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
    
    @IBOutlet weak var button: UIButton!
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var touchMovedCalled = false
    var lineBetweenNearFar : SCNVector3?
    var initialNearFarLine : SCNVector3?
    var userRootNode : SecondTierRoot?
    var hasLocationBeenSaved =  false
    var heading : CLHeading = CLHeading()
    var headingSet : Bool = false

    // MARK: var for emoji
    var ObjNode : SCNNode!
    var name : String! = "bandage"
    let modelExtension = ".obj"
    lazy var modelName = name + modelExtension
    lazy var pathName = "Models.scnassets/" + modelName
    var isEmojiOn : Bool = false
//    let Blue = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)

    //end of MARK


    @IBAction func emojiButtonPressed(_ sender: Any) {
        if(isEmojiOn){
            isEmojiOn = false;
        }else{
            isEmojiOn = true;
        }
        print(isEmojiOn)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//          addPencilKit()
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

//        let test = locationManager.location
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

    //MARK: - Emoji function
    func setModel(){
//        ModelIO
        guard let emojiScene = SCNScene(named:"emojis.scnassets/bandage.scn") else {
            print("model does not exist")
            fatalError()
        }
        ObjNode = emojiScene.rootNode.childNode(withName: "Group50555", recursively: true)
    }
    func emojiLighting(_ anotherNode : SCNNode){
         let estimate: ARLightEstimate!
        estimate = self.sceneView.session.currentFrame?.lightEstimate
        anotherNode.light = SCNLight()
//        anotherNode.light?.intensity = estimate.ambientIntensity
        anotherNode.light?.intensity = 1000
        anotherNode.castsShadow = true
        //                        anotherNode.position = SCNVector3Zeros
        anotherNode.light?.type = SCNLight.LightType.directional
        anotherNode.light?.color = UIColor.white
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor  else { return }
        print("-----------------------> session did add anchor!")
        node.addChildNode(ObjNode)
    }
    //MARK: touch functions
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(isEmojiOn){
            //emoji mode
            if let touch = touches.first {
                let touchPoint = touch.location(in: sceneView)
                self.setModel()
                //add to plane
                let hits = sceneView.hitTest(touchPoint, types: .estimatedHorizontalPlane)
                if hits.count >= 0, let firstHit = hits.first {
                    print("Emoji touch happened at point: \(touchPoint)")
                    //a new emoji placed
                    if let anotherNode = ObjNode?.clone() {
                        anotherNode.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                        //lighting
                        self.sceneView.autoenablesDefaultLighting = true;
                        emojiLighting(anotherNode)
                        sceneView.scene.rootNode.addChildNode(anotherNode)

                    }
                }
            } else {
                    print("Unable to identify touches on any plane. Ignoring interaction...")
                    return
            }
        }else{
            //drawing mode
            if let singleTouch = touches.first{
                let touchLocation = touchLocationIn3D(touch: singleTouch)
                currentStroke = Stroke(firstPoint: touchLocation)
                userRootNode?.addChildNode(currentStroke!)
            } else {
                print("can't get touch")
            }
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //drawing mode
        if(!isEmojiOn){
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
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(!isEmojiOn){
            //        Database().saveDrawing(location: location, userRootNode: userRootNode!)
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
           // load()
        }
//        print("the angle", angle)
        
       // userRootNode?.rotate(by: SCNQuaternion(0, 1, 0, angle), aroundTarget: SCNVector3Make(0, 0, 0))
        //locationManager.stopUpdatingHeading()
    }
    
    @IBAction func save(_ sender: Any) {
        print("hi")
    }
//    func save() {
//        Database().saveDrawing(location: location, userRootNode: userRootNode!)
//    }
    
//    func load() {
//        if !headingSet {
//            return
//        }
//
//        let db = Database()
//        db.retrieveDrawing(location: location, drawFunction: { retrievedNodes in
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
    @IBAction func saveButton(_ sender: Any) {
     //   save()
    }
    @IBAction func loadButton(_ sender: Any) {
     //   load()
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

// debug purposes
extension UIView {

    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

}


func deg2rad(_ number: Double) -> Double {
    return number * .pi / 180
}
