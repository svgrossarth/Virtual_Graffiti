//
//  ViewController.swift
//  scenekittest
//
//  Created by Spencer Grossarth on 2/14/20.
//  Copyright © 2020 Spencer Grossarth. All rights reserved.
//

import UIKit
import ModelIO
import SceneKit
import SceneKit.ModelIO
import ARKit
import PencilKit

class HomeViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, PencilKitInterface, PencilKitDelegate {
    
    @IBOutlet weak var addEmojiButton: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    var pencilKitCanvas =  PKCanvas()
    
    var addingEmoji = false
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var strokeVertices = [SCNVector3]()
    var touchMovedCalled = false
    var previousPoint = SCNVector3()
    var lineBetweenNearFar = SCNVector3()
    var indices = [UInt32]()
    let initialIndices : [UInt32]  = [
        2,5,1, //front
        5,2,6,
        
        
        6,7,4, //second square
        6,4,5,

        3,1,0, //first square
        3,2,1,


        7,0,4, //back
        0,7,3,

        3,6,2, //bottom
        6,3,7,
        
        1,4,0, //top
        1,5,4
        
    ]
    var currentStroke = SCNNode()
    var perviousPoint = SCNVector3()
    var initialNearFarLine = SCNVector3()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addPencilKit()
        self.view.addSubview(sceneView)
        self.view.bringSubviewToFront(addEmojiButton)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        /*let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let source = SCNGeometrySource(vertices: strokeVertices)
        let customGeom = SCNGeometry(sources: [source], elements: [element])
        
        let material = SCNMaterial()
        material.diffuse.contents = PKCanvas().sendColor()
        customGeom.materials = [material]
        
        print(customGeom.materials[0].diffuse.contents)
        
        var dictionaryExample : [String:Any] = ["user":"UserName", "pass":"password", "token":"0123456789", "image":0, "test": customGeom]
        let dataExample: Data = NSKeyedArchiver.archivedData(withRootObject: dictionaryExample)
        let dictionary: Dictionary? = NSKeyedUnarchiver.unarchiveObject(with: dataExample) as! [String : Any]
        
        let geom: SCNGeometry = dictionary!["test"] as! SCNGeometry
        print("reee: ", geom.materials[0].diffuse.contents)
        print("reee part 2")*/
        
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
    
    
    @IBAction func addEmojiButtonTouched(_ sender: Any) {
        addingEmoji = true
        print("Adding emoji")
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
        if addingEmoji == true {
            if let singleTouch = touches.first {
                strokeVertices = [SCNVector3]()
                indices = [UInt32]()
                let touchLocation = singleTouch.location(in: sceneView)
                let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
                let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
                let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
                let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
                initialNearFarLine = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
                let resizedVector  = resizeVector(vector: initialNearFarLine, scalingFactor: 0.3)
                let nodePosition = SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
                print("YOOOO ", nodePosition)
                guard let tempScene = SCNScene(named: "emojis.scnassets/bandage.scn") else {
                    print("file does not exist!")
                    fatalError()
                }
                let modelNode = tempScene.rootNode.childNode(withName: "Group50555", recursively: true)

                modelNode?.position = nodePosition
                //var cubeNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
                //cubeNode.position = SCNVector3(0, 0, -0.2)
                addingEmoji = false
                self.sceneView.scene.rootNode.addChildNode(modelNode!)
            }
        } else {
            if let singleTouch = touches.first {
                strokeVertices = [SCNVector3]()
                indices = [UInt32]()
                let touchLocation = singleTouch.location(in: sceneView)
                let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
                let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
                let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
                let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
                initialNearFarLine = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
                let resizedVector  = resizeVector(vector: initialNearFarLine, scalingFactor: 0.3)
                let nodePosition1 = SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
                previousPoint = nodePosition1
                previousPoint = nodePosition1
            } else {
                print("can't get touch")
            }
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
                
                
                addVertices(point3D: nodePosition1)
                
                previousPoint = nodePosition1
            } else {
                print("can't get touch")
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
    
    func resizeVector(vector: SCNVector3, scalingFactor: Float) -> SCNVector3{
        let length = sqrtf(powf(vector.x, 2) + powf(vector.y, 2) + powf(vector.z, 2))
        return SCNVector3((vector.x/length) * scalingFactor, (vector.y/length) * scalingFactor, (vector.z/length) * scalingFactor)
    }
    
    func addVertices(point3D: SCNVector3){
        let x = point3D.x
        let y = point3D.y
        let z = point3D.z
        let prevX = previousPoint.x
        let prevY = previousPoint.y
        let prevZ = previousPoint.z
        let lineBetweenPoints = SCNVector3(x: x - prevX, y: y - prevY, z: z - prevZ)
        
        if strokeVertices.count == 0 {
            let prevResizedNearFar = resizeVector(vector: initialNearFarLine, scalingFactor: 0.005)
            let prevResizedNormal = resizeVector(vector: crossProduct(vec1: prevResizedNearFar, vec2: lineBetweenPoints), scalingFactor: 0.005)
            strokeVertices = [
                SCNVector3(prevX - prevResizedNearFar.x + prevResizedNormal.x, prevY - prevResizedNearFar.y + prevResizedNormal.y, prevZ - prevResizedNearFar.z + prevResizedNormal.z),
                
                SCNVector3(prevX + prevResizedNearFar.x + prevResizedNormal.x, prevY + prevResizedNearFar.y + prevResizedNormal.y, prevZ + prevResizedNearFar.z + prevResizedNormal.z),
                
                SCNVector3(prevX + prevResizedNearFar.x - prevResizedNormal.x, prevY + prevResizedNearFar.y - prevResizedNormal.y, prevZ + prevResizedNearFar.z - prevResizedNormal.z),
                
                SCNVector3(prevX - prevResizedNearFar.x - prevResizedNormal.x, prevY - prevResizedNearFar.y - prevResizedNormal.y, prevZ - prevResizedNearFar.z - prevResizedNormal.z)
            ]
        }
        let resizedNearFar = resizeVector(vector: lineBetweenNearFar, scalingFactor: 0.005)
        let resizedNormal = resizeVector(vector: crossProduct(vec1: resizedNearFar, vec2: lineBetweenPoints), scalingFactor: 0.005)
        strokeVertices += [
            SCNVector3(x - resizedNearFar.x + resizedNormal.x, y - resizedNearFar.y + resizedNormal.y, z - resizedNearFar.z + resizedNormal.z),
            
            SCNVector3(x + resizedNearFar.x + resizedNormal.x, y + resizedNearFar.y  + resizedNormal.y, z + resizedNearFar.z + resizedNormal.z),
            
            SCNVector3(x + resizedNearFar.x - resizedNormal.x, y + resizedNearFar.y  - resizedNormal.y, z + resizedNearFar.z - resizedNormal.z),
            
            SCNVector3(x - resizedNearFar.x - resizedNormal.x, y - resizedNearFar.y  - resizedNormal.y, z - resizedNearFar.z - resizedNormal.z),
        ]
        connectVertices()
    }
    
    func connectVertices(){
        if indices.count == 0 {
            indices = initialIndices
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let source = SCNGeometrySource(vertices: strokeVertices)
            let customGeom = SCNGeometry(sources: [source], elements: [element])
            
            let material = SCNMaterial()
            material.diffuse.contents = PKCanvas().sendColor()
            customGeom.materials = [material]
            
            currentStroke = SCNNode(geometry: customGeom)
            self.sceneView.scene.rootNode.addChildNode(currentStroke)
        } else {
            // (number of points - 2 becuase already did first 2 points) * 4 becuase 4 vertices per point
            let indexAdder = UInt32(((strokeVertices.count / 4) - 2) * 4)
            
            var newIndices = [UInt32]()
            
            for index in initialIndices {
                newIndices.append(index + indexAdder)
            }
            
            indices += newIndices
            
            let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
            let source = SCNGeometrySource(vertices: strokeVertices)
            let customGeom = SCNGeometry(sources: [source], elements: [element])
            
            let material = SCNMaterial()
            material.diffuse.contents = PKCanvas().sendColor()
            customGeom.materials = [material]

            currentStroke.geometry = customGeom
        }
    }
    
    func crossProduct(vec1: SCNVector3, vec2: SCNVector3) -> SCNVector3{
        return SCNVector3(x: vec1.y * vec2.z - vec1.z * vec2.y, y: vec1.z * vec2.x - vec1.x * vec2.z, z: vec1.x * vec2.y - vec1.y * vec2.x)
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
    
}

// debug purposes
extension UIView {

    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }

}
