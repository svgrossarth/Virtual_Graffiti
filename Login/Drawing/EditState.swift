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
    var distanceSlider = UISlider()
    var distanceValue = UILabel()
    var distanceLabel = UILabel()
    var widthSlider = UISlider()
    var widthLabel = UILabel()
    var drawState = DrawState()
    var refSphere = SCNNode()
    var eraserOn = false
    weak var sceneView: ARSCNView!
    var erasedStake = Stack<Stroke>()
    var undoStake = Stack<Stroke>()
    
    func initialize(eraseButton: UIButton, distanceSlider : UISlider, distanceValue : UILabel, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView, widthSlider : UISlider, widthLabel : UILabel) {
        self.eraseButton = eraseButton
        self.distanceSlider = distanceSlider
        self.distanceLabel = distanceLabel
        self.distanceValue = distanceValue
        self.drawState = drawState
        self.refSphere = refSphere
        self.sceneView = sceneView
        self.widthSlider = widthSlider
        self.widthLabel = widthLabel
    }
    
    func createColorSelector(changeColorButton: UIButton, colorStack: UIStackView) {
        self.changeColorButton = changeColorButton
        self.colorStack = colorStack
    }
    
    
    override func enter() {
        isHidden = false
       // eraserOn = true
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
            eraseButton.backgroundColor = #colorLiteral(red: 0.9576401114, green: 0.7083515525, blue: 0.8352113366, alpha: 1)
        } else {
            eraserOn = true
            eraseButton.backgroundColor = #colorLiteral(red: 0.9938386083, green: 0.3334249258, blue: 0.6164360046, alpha: 1)
        }
    }
    
    func distanceSliderChange() {
        sphereCallbackCanceled = true
        let defaultDistance : Float = 1
        if(distanceSlider.value > 1){
            drawState.distance = defaultDistance * powf(distanceSlider.value, 2)
        } else {
            drawState.distance = defaultDistance * distanceSlider.value
        }
        distanceValue.text = String(format: "%.2f", drawState.distance)
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        drawState.sceneView.scene.rootNode.addChildNode(refSphere)

    }
    
    func widthSliderChange() {
        sphereCallbackCanceled = true
        let defaultWidth : Float = 0.01
        if(widthSlider.value > 1){
            drawState.width = defaultWidth * powf(widthSlider.value, 4)
        } else {
           drawState.width = defaultWidth * widthSlider.value
        }
        widthLabel.text = String(format: "Width: %.3f", drawState.width)
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        refSphere.geometry = SCNSphere(radius: CGFloat(drawState.width))
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
                    if let stroke = hitTestResult.node as? Stroke{
                        stroke.removeFromParentNode()
                        erasedStake.push(stroke)
                    }
                }
            }
        }
    }
    
    func undoErase(){
        if let stroke = erasedStake.pop(){
            undoStake.push(stroke)
            drawState.sceneView.scene.rootNode.addChildNode(stroke)
        }
    }
    
    func redoErase(){
        if let stroke = undoStake.pop(){
            stroke.removeFromParentNode()
            erasedStake.push(stroke)
        }
        
    }
    
    
    
}
