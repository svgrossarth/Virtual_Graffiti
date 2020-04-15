//
//  EditMode.swift
//  Login
//
//  Created by User on 4/5/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import Foundation
import SceneKit
import ARKit


class EditState: State {
    var pencilKitCanvas =  PKCanvas()
    var sphereCallbackCanceled = false
    var colorStack = UIStackView()
    var colors: [UIButton] = []
    var eraseButton = UIButton()
    var changeColorButton = UIButton()
    var slider = UISlider()
    var distanceValue = UILabel()
    var distanceLabel = UILabel()
    var drawState = DrawState()
    var refSphere = SCNNode()
    var eraserOn = false
    weak var sceneView: ARSCNView!
    
    
    func initialize(eraseButton: UIButton, slider : UISlider, distanceValue : UILabel, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView) {
        self.eraseButton = eraseButton
        self.slider = slider
        self.distanceLabel = distanceLabel
        self.distanceValue = distanceValue
        self.drawState = drawState
        self.refSphere = refSphere
        self.sceneView = sceneView
    }
    
    func createColorSelector(changeColorButton: UIButton, colorStack: UIStackView) {
        self.changeColorButton = changeColorButton
        self.colorStack = colorStack
    }
    
    
    override func enter() {
        isHidden = false
        eraserOn = true
    }
    
    
    override func exit() {
        isHidden = true
        eraserOn = false
        self.refSphere.removeFromParentNode()
        
        isHidden = false
    }
    
    func changeColor() {
        if colorStack.isHidden == true {
            colorStack.isHidden = false
        } else {
            colorStack.isHidden = true
        }
    }
    
    func eraseButtonTouchUp() {
        if eraserOn == true {
            eraserOn = false
        } else {
            eraserOn = true
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
