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
    var emojiButton = ModeButton()
    var slider = UISlider()
    var distanceValue = UILabel()
    var distanceLabel = UILabel()
    var drawState = DrawState()
    var refSphere = SCNNode()
    var ObjNode : SCNNode!
    let emojiRootNode = SCNNode()
    var emoji = Emoji(name: "bandage", ID: "Group50555");
    lazy var modelName = String()
    lazy var pathName = String()
    var eraserOn = false
    var EmojiOn = false
    weak var sceneView: ARSCNView!
    
    
    func initialize(emojiButton: ModeButton, eraseButton: UIButton, slider : UISlider, distanceValue : UILabel, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView) {
        self.emojiButton = emojiButton
        self.eraseButton = eraseButton
        self.slider = slider
        self.distanceLabel = distanceLabel
        self.distanceValue = distanceValue
        self.drawState = drawState
        self.refSphere = refSphere
        self.sceneView = sceneView
        modelName = emoji.name + ".scn"
        pathName = "emojis.scnassets/" + modelName
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

    func emojiButtonTouched(){
        if(EmojiOn){
            EmojiOn = false;
        }else{
            EmojiOn = true;
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

    func setModel(){
        guard let emojiScene = SCNScene(named: pathName) else {
            print("model does not exist")
            fatalError()
        }
        ObjNode = emojiScene.rootNode.childNode(withName: emoji.ID, recursively: true)
    }

    func emojiLighting(position: SCNVector3) ->SCNLight{
//        let estimate: ARLightEstimate!
//        estimate = self.sceneView.session.currentFrame?.lightEstimate
        let light = SCNLight()
        light.intensity = 1000
//        light.castsShadow = true
        light.type = SCNLight.LightType.directional
//        light.color = UIColor.white
        return light
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !EmojiOn {
            eraseNode(touches: touches)
        }else{
            if let touch = touches.first {
                let touchPoint = touch.location(in: sceneView)
                self.setModel()
                let hits = sceneView.hitTest(touchPoint, types: .estimatedHorizontalPlane)
                if hits.count >= 0, let firstHit = hits.first {
                    print("Emoji touch happened at point: \(touchPoint)")
                    ObjNode.position = SCNVector3Make(firstHit.worldTransform.columns.3.x, firstHit.worldTransform.columns.3.y, firstHit.worldTransform.columns.3.z)
                    emojiRootNode.light = emojiLighting(position: emojiRootNode.position)
                    emojiRootNode.categoryBitMask = 0
                    self.sceneView.autoenablesDefaultLighting = false
                    emojiRootNode.addChildNode(ObjNode)
                    sceneView.scene.rootNode.addChildNode(emojiRootNode)
                }
            }else {
                 print("Unable to identify touches on any plane. Ignoring interaction...")
            }
        }
    }
     
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !EmojiOn {
            eraseNode(touches: touches)
        }
    }
    
    func eraseNode(touches: Set<UITouch>){
        if eraserOn && !EmojiOn {
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
