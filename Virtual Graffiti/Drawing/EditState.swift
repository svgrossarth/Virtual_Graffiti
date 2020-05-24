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
//    var pencilKitCanvas =  PKCanvas()
    var sphereCallbackCanceled = false
    var menuExpand = false
    var colorStack = UIStackView()
    var colors: [UIButton] = []
    var eraseButton = UIButton()
    var changeColorButton = UIButton()
    var emojiButton = ModeButton()
    var pencilButton = UIButton()
    var signoutButton = UIButton()
    var menuButton = UIButton()
    var distanceSlider = UISlider()
    var distanceLabel = UILabel()
    var widthSlider = UISlider()
    var widthLabel = UILabel()
    var drawState = DrawState()
    var refSphere = SCNNode()
    var ObjNode = SCNNode()
    var emoji = Emoji(name: "bandage", ID: "Group50555");
    lazy var modelName = String()
    lazy var pathName = String()
    var eraserOn = false
    var EmojiOn = false
    var pencilOn = false
    weak var sceneView: ARSCNView!
    var erasedStack = Stack<[String : SCNNode]>()
    var undoStack = Stack<[String : SCNNode]>()
    var recentUsedEmoji = [Emoji]()
    var userUID = ""
    var emojiScale : Float = 1
    var emojiInitialScale : SCNVector3?
    var prePopEmoji = [Emoji]()
    let DavisBlue = UIColor(red: 63/255, green: 87/255, blue: 119/255, alpha: 1)
    
    
    func initialize(signoutButton: UIButton, pencilButton: UIButton, menuButton: UIButton, emojiButton: ModeButton, eraseButton: UIButton, distanceSlider : UISlider, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView, widthSlider : UISlider, widthLabel : UILabel, userUID: String) {
        self.pencilButton = pencilButton
        self.menuButton = menuButton
        self.emojiButton = emojiButton
        self.eraseButton = eraseButton
        self.distanceSlider = distanceSlider
        self.distanceLabel = distanceLabel
        self.drawState = drawState
        self.refSphere = refSphere
        self.sceneView = sceneView
        self.widthSlider = widthSlider
        self.widthLabel = widthLabel
        self.userUID = userUID
        self.signoutButton = signoutButton
        modelName = emoji.name + ".scn"
        pathName = "emojis.scnassets/" + modelName
        self.sceneView.automaticallyUpdatesLighting = false
        let lightNode = SCNNode()
        lightNode.light = directionalLighting()
        sceneView.pointOfView?.addChildNode(lightNode)
    }
    
    func createColorSelector(changeColorButton: UIButton, colorStack: UIStackView) {
        self.changeColorButton = changeColorButton
        self.colorStack = colorStack
    }
    
    
    override func enter() {
        isHidden = false
        self.menuButton.setImage(UIImage(named: "dropDown"), for: .normal)
        widthSlider.minimumTrackTintColor = DavisBlue
        widthSlider.maximumTrackTintColor = .lightGray
        widthSlider.thumbTintColor = DavisBlue
        distanceSlider.minimumTrackTintColor = DavisBlue
        distanceSlider.maximumTrackTintColor = .lightGray
        distanceSlider.thumbTintColor = DavisBlue
    }
    
    
    override func exit() {
        eraserOn = false
        eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
        self.refSphere.removeFromParentNode()
        EmojiOn = false
        menuExpand = false
        emojiButton.deactivateButton()
        isHidden = true
    }

    func menuButtonTouched(){
        UIView.animate(withDuration: 0.3, animations: {
            if !self.menuExpand {
                //open menu
                self.menuButton.transform = .identity
                self.menuExpand = true
                self.menuButton.setImage(UIImage(named: "dropDown"), for: .normal)
                self.eraseButton.transform = CGAffineTransform(translationX: 0, y: 5)
                self.emojiButton.transform = CGAffineTransform(translationX: 0, y: 10)
                self.pencilButton.transform = CGAffineTransform(translationX: 0, y: 15)
                self.changeColorButton.transform = CGAffineTransform(translationX: 0, y: 20)
                self.signoutButton.transform = CGAffineTransform(translationX: 0, y: 25)
                self.emojiButton.isHidden = false
                self.eraseButton.isHidden = false
                self.pencilButton.isHidden = false
                self.changeColorButton.isHidden = false
                self.signoutButton.isHidden = false

                //hide labels and sliders
                self.distanceLabel.isHidden = true
                self.distanceSlider.isHidden = true
                self.widthLabel.isHidden = true
                self.widthSlider.isHidden = true

            }else{
                //close menu
                self.menuExpand = false
                self.changeColorButton.isHidden = true
                self.changeColorButton.setImage(UIImage(named: "colorOff"), for: .normal)
                if self.EmojiOn {
                    self.distanceLabel.isHidden = false
                    self.distanceSlider.isHidden = false

                    self.eraseButton.isHidden = true
                    self.emojiButton.isHidden = false
                    self.colorStack.isHidden = true
                    self.pencilButton.isHidden = true
                    self.signoutButton.isHidden = true

                    self.menuButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.eraseButton.transform = CGAffineTransform(translationX: 0, y: -15)
                    self.emojiButton.transform = CGAffineTransform(translationX: 0, y: -45)//to keep
                    self.pencilButton.transform = CGAffineTransform(translationX: 0, y: -25)
                    self.changeColorButton.transform = CGAffineTransform(translationX: 0, y: -33)
                    self.signoutButton.transform = CGAffineTransform(translationX: 0, y: -41)
                }else if self.eraserOn {
                    self.eraseButton.isHidden = false
                    self.emojiButton.isHidden = true
                    self.pencilButton.isHidden = true
                    self.colorStack.isHidden = true
                    self.changeColorButton.isHidden = true
                    self.signoutButton.isHidden = true

                    self.menuButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.eraseButton.transform = CGAffineTransform(translationX: 0, y: 0)//to keep
                    self.emojiButton.transform = CGAffineTransform(translationX: 0, y: -20)
                    self.pencilButton.transform = CGAffineTransform(translationX: 0, y: -25)
                    self.changeColorButton.transform = CGAffineTransform(translationX: 0, y: -33)
                    self.signoutButton.transform = CGAffineTransform(translationX: 0, y: -41)

                }else if self.pencilOn{
                    self.pencilOn = true

                    self.distanceLabel.isHidden = false
                    self.distanceSlider.isHidden = false
                    self.widthLabel.isHidden = false
                    self.widthSlider.isHidden = false

                    self.eraseButton.isHidden = true
                    self.emojiButton.isHidden = true
                    self.pencilButton.isHidden = false
                    self.colorStack.isHidden = true
                    self.changeColorButton.isHidden = true
                    self.signoutButton.isHidden = true

                    self.menuButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.eraseButton.transform = CGAffineTransform(translationX: 0, y: -15)
                    self.emojiButton.transform = CGAffineTransform(translationX: 0, y: -20)
                    self.pencilButton.transform = CGAffineTransform(translationX: 0, y: -85)//to keep
                    self.changeColorButton.transform = CGAffineTransform(translationX: 0, y: -33)
                    self.signoutButton.transform = CGAffineTransform(translationX: 0, y: -41)
                }else{
                    self.menuButton.setImage(UIImage(named: "dropDown"), for: .normal)
                    self.distanceLabel.isHidden = false
                    self.distanceSlider.isHidden = false
                    self.widthLabel.isHidden = false
                    self.widthSlider.isHidden = false

                    self.colorStack.isHidden = true
                    self.emojiButton.isHidden = true
                    self.eraseButton.isHidden = true
                    self.pencilButton.isHidden = true
                    self.changeColorButton.isHidden = true
                    self.signoutButton.isHidden = true

                    self.menuButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                    self.eraseButton.transform = CGAffineTransform(translationX: 0, y: -15)
                    self.emojiButton.transform = CGAffineTransform(translationX: 0, y: -20)
                    self.pencilButton.transform = CGAffineTransform(translationX: 0, y: -25)
                    self.changeColorButton.transform = CGAffineTransform(translationX: 0, y: -33)
                    self.signoutButton.transform = CGAffineTransform(translationX: 0, y: -41)
                }
            }
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
            if self.menuButton.transform == .identity{
                self.emojiButton.transform = .identity
                self.changeColorButton.transform = .identity
                self.pencilButton.transform = .identity
                self.eraseButton.transform = .identity
                self.signoutButton.transform = .identity
            }
        })
    }
    
    func changeColor() {
        if colorStack.isHidden == true {
            colorStack.isHidden = false
            changeColorButton.setImage(UIImage(named: "colorOn"), for: .normal)
        } else {
            colorStack.isHidden = true
            changeColorButton.setImage(UIImage(named: "colorOff"), for: .normal)
        }
        eraserOn = false
        eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
        EmojiOn = false
        emojiButton.deactivateButton()
    }

    func pencilButtonTouched(){
        pencilOn = true
        pencilButton.setImage(UIImage(named: drawState.currentPen), for: .normal)
//        menuButton.setImage(UIImage(named: drawState.currentPen), for: .normal)
        if eraserOn{
            eraserOn = false
            eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
        }
        if EmojiOn{
            EmojiOn = false
            emojiButton.deactivateButton()
        }
        menuButtonTouched()

        self.distanceLabel.isHidden = false
//        self.distanceValue.isHidden = false
        self.distanceSlider.isHidden = false
        self.widthLabel.isHidden = false
        self.widthSlider.isHidden = false
        colorStack.isHidden = true
    }

    func eraseButtonTouchUp() {
        //turn off eraser
        if eraserOn {
            eraserOn = false
            eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
            if EmojiOn == false && pencilOn == false{
                menuButtonTouched()
            }
        } else {//turn on eraser
            eraserOn = true
            pencilOn = false
            if EmojiOn{
                EmojiOn = false
                emojiButton.deactivateButton()//if eraser is on, deactivate emoji
            }
            eraseButton.setImage(UIImage(named: "eraserOn"), for: .normal)
            pencilButton.setImage(UIImage(named: "pencil"), for: .normal)
            menuButtonTouched()

            self.distanceLabel.isHidden = true
            self.distanceSlider.isHidden = true
            self.widthLabel.isHidden = true
            self.widthSlider.isHidden = true
            colorStack.isHidden = true;

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
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        drawState.rootOfTheScene.addChildNode(refSphere)

    }
    
    func widthSliderChange() {
        sphereCallbackCanceled = true
        let defaultWidth : Float = 0.01
        if(widthSlider.value > 1){
            drawState.width = defaultWidth * powf(widthSlider.value, 4)
            emojiScale = powf(widthSlider.value, 2)
        } else {
            drawState.width = defaultWidth * widthSlider.value
            emojiScale = widthSlider.value
        }
        widthLabel.text = String(format: "Width: %.3f", drawState.width)
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        if EmojiOn{
            let sphereEmojiWidth : Float = emojiScale / 19
            refSphere.geometry = SCNSphere(radius: CGFloat(sphereEmojiWidth))
        } else {
            refSphere.geometry = SCNSphere(radius: CGFloat(drawState.width))
        }
        drawState.rootOfTheScene.addChildNode(refSphere)
        //emojiScale = drawState.width / defaultWidth
        print("drawing state width", drawState.width)
        print("emoji scale", emojiScale)

    }
    
    func removeSphere(){
        sphereCallbackCanceled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if !self.sphereCallbackCanceled {
                self.refSphere.removeFromParentNode()
            }
        }
    }

    //MARK: Emoji Functions
    func emojiButtonTouched(){
        if !EmojiOn{
            EmojiOn = true;
            pencilOn = false
            emojiButton.activateButton(imageName: emoji.name)
            if eraserOn {
                eraserOn = false
                eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
            }
            pencilButton.setImage(UIImage(named: "pencil"), for: .normal)
            colorStack.isHidden = true;
            self.distanceLabel.isHidden = false
            self.distanceSlider.isHidden = false
            self.widthLabel.isHidden = true
            self.widthSlider.isHidden = true
            colorStack.isHidden = true;
            menuButtonTouched()
        }else{
            EmojiOn = false
            emojiButton.deactivateButton()
            if eraserOn == false && pencilOn == false{
                menuButtonTouched()
            }
        }
    }

    func setModel(){
        print("pathname:",pathName)
        guard let emojiScene = SCNScene(named: pathName) else {
            print("model with path: ", pathName," does not exist")
            fatalError()
        }
        ObjNode = emojiScene.rootNode.childNode(withName: emoji.ID, recursively: true)!
    }

    func directionalLighting() ->SCNLight{
        let light = SCNLight()
        light.type = SCNLight.LightType.directional
        light.categoryBitMask = 1
        light.intensity = 500

        return light
    }

    func stateChangeEmoji(emoji: Emoji){
        self.emoji = emoji
        self.modelName = emoji.name + ".scn"
        self.pathName = "emojis.scnassets/" + modelName
        print("EditState change emoji:", emoji.name)
    }

    func getEmojiList() -> [Emoji]{
        print("recent used emoji:", recentUsedEmoji.count)
        return recentUsedEmoji
    }

    func setupRecentList(){
        prePopEmoji.append(Emoji(name:"bandage", ID:"Group50555" ))
        prePopEmoji.append(Emoji(name:"tired", ID:"Group3677"))
        prePopEmoji.append(Emoji(name:"very happy", ID:"Group19895"))
    }

    func updateRecentEmojiList(){
        if recentUsedEmoji.contains(emoji) {
             recentUsedEmoji.remove(at: recentUsedEmoji.firstIndex(of: emoji)!)
        }else if recentUsedEmoji.count == 5{
            recentUsedEmoji.popLast()
        }
        recentUsedEmoji.insert(emoji, at: 0)
    }

    func degToRadians(degrees:Double) -> Double
    {
       return degrees * (Double.pi / 180);
     }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if EmojiOn {
            if menuExpand {
                menuButtonTouched()
//                menuButton.setImage(UIImage(named: emoji.name), for: .normal)
            }
            if let singleTouch = touches.first{
                let touchLocation = drawState.touchLocationIn3D(touchLocation2D: singleTouch.location(in: sceneView))
                self.setModel()

                let cloneEmoji = ObjNode.clone()
                cloneEmoji.position = touchLocation
                cloneEmoji.categoryBitMask = 1
                if emojiInitialScale == nil {
                    emojiInitialScale = cloneEmoji.scale
                }
                //cloneEmoji.scale = SCNVector3(emojiScale, emojiScale, emojiScale)
                guard let initialScale = emojiInitialScale else {
                    print("Can't get scale")
                    return
                }
                cloneEmoji.scale = SCNVector3(initialScale.x * emojiScale, initialScale.y * emojiScale, initialScale.z * emojiScale)
                //  cloneEmoji facing to User Screen
                let screenOrientation = sceneView.pointOfView?.orientation
                cloneEmoji.orientation = screenOrientation!
                // animation moving up/down
                let moveDown = SCNAction.move(by: SCNVector3(0, -0.05, 0), duration: 1)
                let moveUp = SCNAction.move(by: SCNVector3(0,0.05
                    ,0), duration: 1)
//                let waitAction = SCNAction.wait(duration: 0.25)
                let hoverSequence = SCNAction.sequence([moveUp,moveDown])
                let loopSequence = SCNAction.repeatForever(hoverSequence)
                cloneEmoji.runAction(loopSequence)

                drawState.userRootNode.addChildNode(cloneEmoji)
//                updateRecentEmojiList()
            } else {
                print("can't get touch")
            }
        }else if !EmojiOn{
            if menuExpand && !eraserOn{
                let penName = drawState.currentPen
                menuButtonTouched()
//                menuButton.setImage(UIImage(named: penName), for: .normal)
            }
            eraseNode(touches: touches)
        }
    }
     
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if eraserOn{
            if menuExpand {
                menuButtonTouched()
            }
            eraseNode(touches: touches)
        }
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
                    let userRootNode = hitTestResult.node.parent as? SecondTierRoot
                    if userRootNode?.uid == userUID {
                        if let _ = hitTestResult.node.geometry{
                            guard let parent = hitTestResult.node.parent as? SecondTierRoot else {
                                print("can't get parent")
                                return
                            }
                            if let parentName = parent.name {
                                hitTestResult.node.removeFromParentNode()
                                erasedStack.push([parentName : hitTestResult.node])
                                if let qrNode = parent.parent as? QRNode{
                                    Database().saveQRNode(qrNode: qrNode)
                                }
                                if drawState.locationPermission {
                                    Database().saveDrawing(userRootNode: parent)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func undoErase(){
        if let stroke = erasedStack.pop(){
            undoStack.push(stroke)
            guard let parentName = stroke.first?.key else {
                print("can't get parent name")
                return
            }
            guard let drawingNode = stroke.first?.value else {
                print("can't get drawing node")
                return
            }
            for node in drawState.rootOfTheScene.childNodes {
                if let qrNode = node as? QRNode{
                    guard let userRootNode = qrNode.childNodes.first as? SecondTierRoot else {
                        print("can't get userRootNode from qrNode")
                        return
                    }
                    if parentName == userRootNode.name{
                        userRootNode.addChildNode(drawingNode)
                        Database().saveQRNode(qrNode: qrNode)
                        if drawState.locationPermission {
                            Database().saveDrawing(userRootNode: userRootNode)
                        }
                        return
                    }
                } else if let userRootNode = node as? SecondTierRoot {
                    if parentName == userRootNode.name{
                        userRootNode.addChildNode(drawingNode)
                        if drawState.locationPermission{
                            Database().saveDrawing(userRootNode: userRootNode)
                        }
                        return
                    }
                }
            }
        }
    }
    
    func redoErase(){
        if let stroke = undoStack.pop(){
            guard let drawingNode = stroke.first?.value else {
                print("can't get drawing node")
                return
            }
            if let userRootNode = drawingNode.parent as? SecondTierRoot{
                if let qrNode = userRootNode.parent as? QRNode {
                    Database().saveQRNode(qrNode: qrNode)
                }
                if drawState.locationPermission {
                    Database().saveDrawing(userRootNode: userRootNode)
                }
            }
            drawingNode.removeFromParentNode()
            erasedStack.push(stroke)
        }
    }
}


class CustomSlider: UISlider {
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: 10))
    }
}
