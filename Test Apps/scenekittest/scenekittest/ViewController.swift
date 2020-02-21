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

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var cameraTrans = simd_float4()
    var previousNode = SCNNode()
    var strokeVertices = [SCNVector3]()
    var touchMovedCalled = false
    var previousPoint = SCNVector3()
    
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
        
        
        let geom = SCNSphere(radius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        geom.materials = [material]

        let sphereNode = SCNNode(geometry: geom)
        self.sceneView.scene.rootNode.addChildNode(sphereNode)

        
//        let rootNode = SCNNode()
//        sceneView.scene.rootNode
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
            touchMovedCalled = false
            var touchLocation = singleTouch.location(in: sceneView)
            let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
            let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
            let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
            let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
            let lineBetweenPoints = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
            let resizedVector  = resizeVector(vector: lineBetweenPoints, scalingFactor: 0.3)
            let nodePosition1 = SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
            
            setInitialVertices(point3D: nodePosition1)
            
            print("first touch", nodePosition1)
            
            let geom = SCNSphere(radius: 0.01)
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.green
            geom.materials = [material]
            
            let sphereNode = SCNNode(geometry: geom)
            //sphereNode.position = nodePosition1
            //sphereNode.position = nodePosition1
            sphereNode.worldPosition = nodePosition1
            //self.sceneView.scene.rootNode.addChildNode(sphereNode)
            previousNode = sphereNode
            previousPoint = nodePosition1
        } else {
            print("can't get touch")
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //print("touches Moved")
        if touchMovedCalled == false {
            touchMovedCalled = true
            if let singleTouch = touches.first{
                let test = sceneView.scene.rootNode.worldPosition
                var touchLocation = singleTouch.location(in: sceneView)
                let pointToUnprojectNear = SCNVector3(touchLocation.x, touchLocation.y, 0)
                let pointToUnprojectFar = SCNVector3(touchLocation.x, touchLocation.y, 1)
                let pointIn3dNear = sceneView.unprojectPoint(pointToUnprojectNear)
                let pointIn3dFar = sceneView.unprojectPoint(pointToUnprojectFar)
                let lineBetweenPoints = SCNVector3(x: pointIn3dFar.x - pointIn3dNear.x, y: pointIn3dFar.y - pointIn3dNear.y, z: pointIn3dFar.z - pointIn3dNear.z)
                let resizedVector  = resizeVector(vector: lineBetweenPoints, scalingFactor: 0.3)
                let nodePosition1 = SCNVector3(pointIn3dNear.x + resizedVector.x, pointIn3dNear.y + resizedVector.y, pointIn3dNear.z + resizedVector.z)
                let nodePosition2 = SCNVector3(self.cameraTrans.x + resizedVector.x, self.cameraTrans.y + resizedVector.y, self.cameraTrans.y + resizedVector.z)
                
                
                addVertices(point3D: nodePosition1)
                
                print("second touch", nodePosition1)
                
                
                let clone = self.previousNode.clone()
                //clone.position = nodePosition1
                
                clone.worldPosition = nodePosition1
                // previousNode.addChildNode(clone)
                clone.worldPosition = nodePosition1
                
                //self.sceneView.scene.rootNode.addChildNode(clone)
                extendStroke(currentPoint: nodePosition1)
                //generateMorePoints(currentPoint : clone)
                self.previousNode = clone
                // print("hi")
            } else {
                print("can't get touch")
            }
            
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
    
    func generateMorePoints(currentPoint : SCNNode){
        let currentPointPosition = currentPoint.position
        let previousPointPosition = self.previousNode.position
//        let currentPointPosition = currentPoint.worldPosition
//        let previousPointPosition = self.previousNode.worldPosition

        let distance = distanceBetweenPoints(currentPointPosition: currentPointPosition, previousPointPosition: previousPointPosition)
        if(distance >= 0.002){
            renderPoints(currentPointPosition: currentPointPosition, previousPointPosition: previousPointPosition, distance:distance)
        }
    }
    
    func extendStroke(currentPoint : SCNVector3){
        let distance = distanceBetweenPoints(currentPointPosition: currentPoint, previousPointPosition: previousPoint)
        renderExtendedStroke(currentPointPosition: currentPoint, previousPointPosition: previousPoint, distance:distance)
    }
    
    func distanceBetweenPoints(currentPointPosition : SCNVector3, previousPointPosition : SCNVector3) -> Float {
        
        let xDist = (currentPointPosition.x - previousPointPosition.x)
        let yDist = (currentPointPosition.y - previousPointPosition.y)
        let zDist = (currentPointPosition.z - previousPointPosition.z)
        return sqrtf(pow(xDist, 2) + pow(yDist, 2) + pow(zDist, 2))
    }
    
    
    func renderExtendedStroke(currentPointPosition: SCNVector3, previousPointPosition: SCNVector3, distance : Float){
        //print("rendering points")
        let lineBetweenPoints = SCNVector3(x: currentPointPosition.x - previousPointPosition.x, y: currentPointPosition.y - previousPointPosition.y, z: currentPointPosition.z - previousPointPosition.z)


    }
    
    func renderPoints(currentPointPosition: SCNVector3, previousPointPosition: SCNVector3, distance : Float){
        //print("rendering points")
        let lineBetweenPoints = SCNVector3(x: currentPointPosition.x - previousPointPosition.x, y: currentPointPosition.y - previousPointPosition.y, z: currentPointPosition.z - previousPointPosition.z)
        let smallStep : Float = 0.002
        let num = Int(distance/smallStep)
        if num == 1 {
            let clone = self.previousNode.clone()
            let midPoint = SCNVector3(x: lineBetweenPoints.x * 0.5, y: lineBetweenPoints.y * 0.5, z: lineBetweenPoints.z * 0.5)
            //clone.position = SCNVector3(x: previousPointPosition.x + midPoint.x, y: previousPointPosition.y + midPoint.y, z: previousPointPosition.z + midPoint.z)
            //previousNode.addChildNode(clone)
            clone.worldPosition = SCNVector3(x: previousPointPosition.x + midPoint.x, y: previousPointPosition.y + midPoint.y, z: previousPointPosition.z + midPoint.z)
            //self.sceneView.scene.rootNode.addChildNode(clone)
            
        } else {
            for i in 1...num - 1 {
                
                let clone = self.previousNode.clone()
                let scaleFactor = Float(i)/Float(num)
                let scaledPoint = SCNVector3(x: lineBetweenPoints.x * scaleFactor, y: lineBetweenPoints.y * scaleFactor, z: lineBetweenPoints.z * scaleFactor)
               // clone.position = SCNVector3(x: previousPointPosition.x + scaledPoint.x, y: previousPointPosition.y + scaledPoint.y, z: previousPointPosition.z + scaledPoint.z)
                //previousNode.addChildNode(clone)
                clone.worldPosition = SCNVector3(x: previousPointPosition.x + scaledPoint.x, y: previousPointPosition.y + scaledPoint.y, z: previousPointPosition.z + scaledPoint.z)
               // self.sceneView.scene.rootNode.addChildNode(clone)
                
                
            }


        }


    }
    
    func findRotation(currentPointPosition: simd_float3, previousPointPosition: simd_float3, distance : Float) -> simd_quatf{
        var oppositeSide = Float()
        var angle = Float()

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
        }

        return simd_quatf(angle: angle, axis: simd_float3(x: 0, y: 0, z: 1))
    }
    
    func setInitialVertices(point3D: SCNVector3){
        let x = point3D.x
        let y = point3D.y
        let z = point3D.z
        strokeVertices = [
            SCNVector3(x, y + 0.01 , z - 0.01),
            SCNVector3(x, y + 0.01 , z + 0.01),
            SCNVector3(x, y - 0.01 , z + 0.01),
            SCNVector3(x, y - 0.01 , z - 0.01),
        ]
//        strokeVertices = [
//            SCNVector3(x - 0.1, y + 0.1 , z ),
//            SCNVector3(x + 0.1, y + 0.1 , z ),
//            SCNVector3(x + 0.1, y - 0.1 , z ),
//            SCNVector3(x - 0.1, y - 0.1 , z ),
//        ]
        print(strokeVertices)
  //      testVertices()
        
    }
    
    func addVertices(point3D: SCNVector3){
        let x = point3D.x
        let y = point3D.y
        let z = point3D.z
        strokeVertices += [
            SCNVector3(x, y + 0.01 , z - 0.01),
            SCNVector3(x, y + 0.01 , z + 0.01),
            SCNVector3(x, y - 0.01 , z + 0.01),
            SCNVector3(x, y - 0.01 , z - 0.01),
        ]

        print(strokeVertices)
        connectVertices()
    }
    
    func connectVertices(){
        let indices: [UInt16] = [
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
        
        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
        let source = SCNGeometrySource(vertices: strokeVertices)
        let customGeom = SCNGeometry(sources: [source], elements: [element])
//        let material = SCNMaterial()
//        material.isDoubleSided = true
//        customGeom.materials = [material]
        let node = SCNNode(geometry: customGeom)
        self.sceneView.scene.rootNode.addChildNode(node)
        
    }
    
    
//    func testVertices(){
//        let indices: [UInt16] = [
//            3,1,0,
//            1,3,2
//
//
////            4,7,6, //second square
////            4,5,6,
////
////            0,1,5, //top
////            0,4,5,
////
////            1,2,6, //front
////            1,5,6,
////
////            0,3,7, //back
////            0,4,7,
////
////            2,3,7, //bottom
////            2,6,6
//        ]
//
//        let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
//        let source = SCNGeometrySource(vertices: strokeVertices)
//        let customGeom = SCNGeometry(sources: [source], elements: [element])
//
//        let node = SCNNode(geometry: customGeom)
//        self.sceneView.scene.rootNode.addChildNode(node)
//
//    }
    
    
    
    
}
