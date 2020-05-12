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
    var menuExpand = false
    var colorStack = UIStackView()
    var colors: [UIButton] = []
    var eraseButton = UIButton()
    var changeColorButton = UIButton()
    var emojiButton = ModeButton()
    var pencilButton = UIButton()
    var menuButton = UIButton()
    var distanceSlider = UISlider()
    var distanceValue = UILabel()
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
    var pencilOn = true
    weak var sceneView: ARSCNView!
    var erasedStack = Stack<[String : SCNNode]>()
    var undoStack = Stack<[String : SCNNode]>()
    var recentUsedEmoji = [Emoji]()
    var userUID = ""
    var emojiScale : Float = 1
    var emojiInitialScale : SCNVector3?
    var prePopEmoji = [Emoji]()
    
    
    func initialize(pencilButton: UIButton, menuButton: UIButton, emojiButton: ModeButton, eraseButton: UIButton, distanceSlider : UISlider, distanceValue : UILabel, distanceLabel : UILabel, drawState : DrawState, refSphere : SCNNode, sceneView : ARSCNView, widthSlider : UISlider, widthLabel : UILabel, userUID: String) {
        self.pencilButton = pencilButton
        self.menuButton = menuButton
        self.emojiButton = emojiButton
        self.eraseButton = eraseButton
        self.distanceSlider = distanceSlider
        self.distanceLabel = distanceLabel
        self.distanceValue = distanceValue
        self.drawState = drawState
        self.refSphere = refSphere
        self.sceneView = sceneView
        self.widthSlider = widthSlider
        self.widthLabel = widthLabel
        self.userUID = userUID
        modelName = emoji.name + ".scn"
        pathName = "emojis.scnassets/" + modelName
        self.sceneView.automaticallyUpdatesLighting = false
    }
    
    func createColorSelector(changeColorButton: UIButton, colorStack: UIStackView) {
        self.changeColorButton = changeColorButton
        self.colorStack = colorStack
    }
    
    
    override func enter() {
        isHidden = false
//        LoadRecentEmoji()
        self.menuButton.setImage(UIImage(named: "dropDown"), for: .normal)
        widthSlider.minimumTrackTintColor = .darkGray
        widthSlider.maximumTrackTintColor = .lightGray
        widthSlider.thumbTintColor = .darkGray
        distanceSlider.minimumTrackTintColor = .darkGray
        distanceSlider.maximumTrackTintColor = .lightGray
        distanceSlider.thumbTintColor = .darkGray

    }
    
    
    override func exit() {
        eraserOn = false
        eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
        self.refSphere.removeFromParentNode()
        EmojiOn = false
        menuExpand = false
        emojiButton.deactivateButton()
        isHidden = true
        saveRecentEmoji()
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
                self.emojiButton.isHidden = false
                self.eraseButton.isHidden = false
                self.pencilButton.isHidden = false
                self.changeColorButton.isHidden = false

                //hide labels and sliders
                self.distanceLabel.isHidden = true
                self.distanceValue.isHidden = true
                self.distanceSlider.isHidden = true
                self.widthLabel.isHidden = true
                self.widthSlider.isHidden = true

            }else{
                //close menu
                self.menuExpand = false
                self.menuButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
                self.eraseButton.transform = CGAffineTransform(translationX: 0, y: -15)
                self.emojiButton.transform = CGAffineTransform(translationX: 0, y: -20)
                self.pencilButton.transform = CGAffineTransform(translationX: 0, y: -25)
                self.changeColorButton.transform = CGAffineTransform(translationX: 0, y: -35)
                self.colorStack.isHidden = true
                self.emojiButton.isHidden = true
                self.eraseButton.isHidden = true
                self.pencilButton.isHidden = true
                self.changeColorButton.isHidden = true
                self.changeColorButton.setImage(UIImage(named: "colorOff"), for: .normal)
                if self.EmojiOn {
                    self.menuButton.setImage(UIImage(named: self.emoji.name), for: .normal)
                }else if self.eraserOn {
                    self.menuButton.setImage(UIImage(named: "eraserOn"), for: .normal)
                }else{
                    self.pencilOn = true
                    self.menuButton.setImage(UIImage(named: self.drawState.currentPen), for: .normal)
                    self.distanceLabel.isHidden = false
                    self.distanceValue.isHidden = false
                    self.distanceSlider.isHidden = false
                    self.widthLabel.isHidden = false
                    self.widthSlider.isHidden = false
                }
            }
        })
        UIView.animate(withDuration: 0.3, delay: 0.2, options: [], animations: {
            if self.menuButton.transform == .identity{
                self.emojiButton.transform = .identity
                self.changeColorButton.transform = .identity
                self.pencilButton.transform = .identity
                self.eraseButton.transform = .identity
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
        menuButton.setImage(UIImage(named: drawState.currentPen), for: .normal)
        if eraserOn{
            eraseButtonTouchUp()
        }
        if EmojiOn{
            EmojiOn = false
            emojiButton.deactivateButton()
        }
        menuButtonTouched()

        self.distanceLabel.isHidden = false
        self.distanceValue.isHidden = false
        self.distanceSlider.isHidden = false
        self.widthLabel.isHidden = false
        self.widthSlider.isHidden = false
        colorStack.isHidden = true
    }

    func eraseButtonTouchUp() {
        if eraserOn == true {
            eraserOn = false
            eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
            if EmojiOn == false && pencilOn == false{
                pencilButtonTouched()
            }
        } else {
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
            self.distanceValue.isHidden = true
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
        distanceValue.text = String(format: "%.2f", drawState.distance)
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        guard let sceneNode = drawState.sceneView.sceneNode else {
            print("ERROR: sceneNode not available to place refSphere, this is a problem with the new ARCL library")
            return
        }
        sceneNode.addChildNode(refSphere)

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
        //emojiScale = widthSlider.value
        widthLabel.text = String(format: "Width: %.3f", drawState.width)
        let screenCenter = CGPoint(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        refSphere.position = drawState.touchLocationIn3D(touchLocation2D: screenCenter)
        if EmojiOn{
            let sphereEmojiWidth : Float = emojiScale / 19
            refSphere.geometry = SCNSphere(radius: CGFloat(sphereEmojiWidth))
        } else {
            refSphere.geometry = SCNSphere(radius: CGFloat(drawState.width))
        }
        guard let sceneNode = drawState.sceneView.sceneNode else {
            print("ERROR: sceneNode not available to place refSphere, this is a problem with the new ARCL library")
            return
        }
        sceneNode.addChildNode(refSphere)
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
            EmojiOn = true;
            pencilOn = false
            emojiButton.activateButton(imageName: emoji.name)
            menuButton.setImage(UIImage(named: emoji.name), for: .normal)
            menuButtonTouched()
            if eraserOn {
                eraseButtonTouchUp()// if emoji is on, deactivate eraser
            }
            pencilButton.setImage(UIImage(named: "pencil"), for: .normal)
            colorStack.isHidden = true;
            self.distanceLabel.isHidden = false
            self.distanceValue.isHidden = false
            self.distanceSlider.isHidden = false
            self.widthLabel.isHidden = false
            self.widthSlider.isHidden = false
            colorStack.isHidden = true;
    }

    func saveRecentEmoji(){
        //TODO:
    }

    func LoadRecentEmoji(){
        //TODO:
    }

    func setModel(){
        guard let emojiScene = SCNScene(named: pathName) else {
            print("model with path: ", pathName," does not exist")
            fatalError()
        }
        ObjNode = emojiScene.rootNode.childNode(withName: emoji.ID, recursively: true)!
    }

    func emojiLighting() ->SCNLight{
        let light = SCNLight()
        light.type = SCNLight.LightType.ambient
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
        if prePopEmoji.count == 0 {
            setupRecentList()
        }
        if recentUsedEmoji.count == 0{
            print("prePopEmoji emoji:", prePopEmoji.count)
            return prePopEmoji
        }
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
       return degrees * (M_PI / 180);
     }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if menuExpand {
            menuButtonTouched()
            menuButton.setImage(UIImage(named: emoji.name), for: .normal)
        }
        if EmojiOn {
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
                drawState.userRootNode.addChildNode(cloneEmoji)
                menuButton.setImage(UIImage(named: emoji.name), for: .normal)
                updateRecentEmojiList()
            } else {
                print("can't get touch")
            }
        }else if !EmojiOn{
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
                                Database().saveDrawing(userRootNode: parent)
                                if let qrNode = parent.parent as? QRNode{
                                    Database().saveQRNode(qrNode: qrNode)
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
            guard let sceneNode = drawState.sceneView.sceneNode else {
                print("ERROR: sceneNode not available to remove stroke, this is a problem with the new ARCL library")
                return
            }
            guard let parentName = stroke.first?.key else {
                print("can't get parent name")
                return
            }
            guard let drawingNode = stroke.first?.value else {
                print("can't get drawing node")
                return
            }
            for node in sceneNode.childNodes {
                if let qrNode = node as? QRNode{
                    guard let userRootNode = qrNode.childNodes.first as? SecondTierRoot else {
                        print("can't get userRootNode from qrNode")
                        return
                    }
                    if parentName == userRootNode.name{
                        userRootNode.addChildNode(drawingNode)
                        Database().saveDrawing(userRootNode: userRootNode)
                        Database().saveQRNode(qrNode: qrNode)
                        return
                    }
                } else if let userRootNode = node as? SecondTierRoot {
                    if parentName == userRootNode.name{
                        userRootNode.addChildNode(drawingNode)
                        Database().saveDrawing(userRootNode: userRootNode)
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
            drawingNode.removeFromParentNode()
            if let userRootNode = drawingNode.parent as? SecondTierRoot{
                if let qrNode = userRootNode.parent as? QRNode {
                    Database().saveQRNode(qrNode: qrNode)
                }
                Database().saveDrawing(userRootNode: userRootNode)
            }
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
