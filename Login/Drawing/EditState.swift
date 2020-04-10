//
//  EditMode.swift
//  Login
//
//  Created by User on 4/5/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import PencilKit
import SceneKit
import ARKit


class EditState: State {
    var pencilKitCanvas =  PKCanvas()
    var sphereCallbackCanceled = false
    var slider = UISlider()
    var distanceValue = UILabel()
    var distanceLabel = UILabel()
    var drawState = DrawState()
    var refSphere = SCNNode()
    var eraserOn = false
    weak var sceneView: ARSCNView!
    
    
    func initialize(slider : UISlider, distanceValue : UILabel, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView) {
        self.slider = slider
        self.distanceLabel = distanceLabel
        self.distanceValue = distanceValue
        self.drawState = drawState
        self.refSphere = refSphere
        self.sceneView = sceneView
        updateCanvasOrientation(with: bounds)
        addPencilKit()
    }
    
    
    override func enter() {
        isHidden = false
        if let window = UIApplication.shared.windows.last, let toolPicker = PKToolPicker.shared(for: window) {
            //toolpicker shows up
            toolPicker.setVisible(true, forFirstResponder: pencilKitCanvas.canvasView)
            if let eraser = toolPicker.selectedTool as? PKEraserTool {
                eraserOn = true
            }
        }
        
    }
    
    
    override func exit() {
        isHidden = true
        eraserOn = false
        self.refSphere.removeFromParentNode()
        
        isHidden = false
        if let window = UIApplication.shared.windows.last, let toolPicker = PKToolPicker.shared(for: window) {
           //toolpicker shows up
            toolPicker.setVisible(false, forFirstResponder: pencilKitCanvas.canvasView)
           }
    }
    
    func sliderValueChange() {
        sphereCallbackCanceled = true
        let defaultDistance : Float = 1
        if(slider.value > 1){
            drawState.distance = defaultDistance * powf(slider.value, 2)
        } else {
           drawState.distance = defaultDistance * slider.value
        }
        distanceValue.text = String(format: "%.2f", drawState.distance)
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        drawState.sceneView.scene.rootNode.addChildNode(refSphere)

    }
    
    func removeSphere(){
        sphereCallbackCanceled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !self.sphereCallbackCanceled {
                self.refSphere.removeFromParentNode()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        eraseNode(touches: touches)
    }
     
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        eraseNode(touches: touches)
    }
    
    func eraseNode(touches: Set<UITouch>){
        if eraserOn {
            if touches.count == 1 {
                guard let touch = touches.first else {
                    print ("can't get first touch")
                    return
                }
                let touchPosition = touch.location(in: sceneView)
                let hitTestResults = sceneView.hitTest(touchPosition)
                for hitTestResult in hitTestResults{
                    let node = hitTestResult.node
                    node.removeFromParentNode()
                }
            }
        }
        
    }
    
}



extension EditState: PencilKitInterface, PencilKitDelegate {
    // Create a canvas view and make it a subview of ARSCNView so that the ToolPicker shows up and lets us change the color
    private func addPencilKit() {
        backgroundColor = .clear
        pencilKitCanvas  = createPencilKitCanvas(frame: frame, delegate: self)
        addSubview(pencilKitCanvas)
        
        
    }
    
}
