//
//  ViewController.swift
//  scenekittest
//
//  Created by Spencer Grossarth on 2/14/20.
//  Copyright © 2020 Spencer Grossarth. All rights reserved.
//

//Icons made by <a href="https://www.flaticon.com/authors/google" title="Google">Google</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

//Icons made by <a href="https://www.flaticon.com/authors/google" title="Google">Google</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

//Icons made by <a href="https://www.flaticon.com/authors/pixel-perfect" title="Pixel perfect">Pixel perfect</a> from <a href="https://www.flaticon.com/" title="Flaticon"> www.flaticon.com</a>

//https://iconsplace.com/custom-color/pencil-icon/

import UIKit
import SceneKit
import ARKit
import CoreLocation
import SwiftUI

class HomeViewController: UIViewController {
    var drawState = DrawState()
    var editState = EditState()
    var state : State = State()
    var refSphere = SCNNode()
    var sphereCallbackCanceled = false
    var doubleTapHappened = false
    var EmojiOn : Bool = false
    var emoji = Emoji(name: "bandage", ID: "Group50555");
    
    @IBOutlet weak var colorStack: UIStackView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet weak var pencilButton: UIButton!
    @IBOutlet weak var eraseButton: UIButton!
    @IBOutlet weak var changeColorButton: UIButton!
    
    @IBOutlet weak var distanceSlider: UISlider!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var widthSlider: UISlider!
    @IBOutlet weak var widthLabel: UILabel!
    

    @IBOutlet weak var undo: UIButton!
    @IBOutlet weak var redo: UIButton!

    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var emojiButton: ModeButton!
    @IBOutlet weak var sceneView: SceneLocationView!
    var userUID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(drawState)
        drawState.initialize(_sceneView: sceneView, userUID: userUID)
        
        state = drawState
        state.enter()
        uiSetup()

        eraseButton.setImage(UIImage(named: "eraserOff"), for: .normal)
        changeColorButton.setImage(UIImage(named: "colorOff"), for: .normal)

        view.addSubview(editState)
        editState.initialize(pencilButton: pencilButton, menuButton: menuButton, emojiButton: emojiButton, eraseButton: eraseButton, distanceSlider: distanceSlider, distanceValue: distanceValue, distanceLabel: distanceLable, drawState: drawState, refSphere: refSphere, sceneView: sceneView, widthSlider: widthSlider, widthLabel: widthLabel, userUID: userUID)
        editState.createColorSelector(changeColorButton: changeColorButton, colorStack: colorStack)

    }
    
    func uiSetup () {
        distanceSlider.transform = CGAffineTransform(rotationAngle: .pi / -2)
        distanceSlider.minimumValue = 0.2
        distanceSlider.maximumValue = 2
        distanceSlider.value = 1
        distanceValue.text = String(format: "%.2f", distanceSlider.value)
        widthSlider.minimumValue = 0.2
        widthSlider.maximumValue = 2
        widthSlider.value = 1
        widthLabel.text = String(format: "Width: %.3f", drawState.width)
        blueButton.layer.cornerRadius = 0.5 * blueButton.bounds.size.width
        redButton.layer.cornerRadius = 0.5 * redButton.bounds.size.width
        greenButton.layer.cornerRadius = 0.5 * greenButton.bounds.size.width
        yellowButton.layer.cornerRadius = 0.5 * yellowButton.bounds.size.width
        orangeButton.layer.cornerRadius = 0.5 * orangeButton.bounds.size.width
        self.view.bringSubviewToFront(distanceSlider)
        self.view.bringSubviewToFront(distanceLable)
        self.view.bringSubviewToFront(distanceValue)
        self.view.bringSubviewToFront(changeColorButton)
        self.view.bringSubviewToFront(eraseButton)
        self.view.bringSubviewToFront(menuButton)
        self.view.bringSubviewToFront(colorStack)
        self.view.bringSubviewToFront(widthLabel)
        self.view.bringSubviewToFront(widthSlider)
        self.view.bringSubviewToFront(undo)
        self.view.bringSubviewToFront(redo)
        self.view.bringSubviewToFront(emojiButton)
        self.view.bringSubviewToFront(pencilButton)
        refSphere = createReferenceSphere()
        changeHiddenOfEditMode()
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        state.exit()
    }
    
    
    func changeState(nextState : State) {
        changeHiddenOfEditMode()
        state.exit()
        state = nextState
        state.enter()
        if state == drawState {
            print("Entered Draw State")
        }
        else {
            print("Entered Edit State")
        }
    }
    
    @IBAction func pencilButton(_ sender: Any) {
        editState.pencilButtonTouched()
    }

    @IBAction func redButton(_ sender: Any) {
        print("red button clicked")
        drawState.drawingColor = .systemRed
        changeColorButton.setImage(UIImage(named: "colorOn"), for: .normal)
        drawState.currentPen = "redPen"
        editState.pencilButtonTouched()
        colorStack.isHidden = true
    }
    @IBAction func orangeButton(_ sender: Any) {
        print("orange button clicked")
        drawState.drawingColor = .systemOrange
        changeColorButton.setImage(UIImage(named: "colorOn"), for: .normal)
        drawState.currentPen = "orangePen"
        editState.pencilButtonTouched()
        colorStack.isHidden = true
    }
    @IBAction func yellowButton(_ sender: Any) {
        print("yellow button clicked")
        drawState.drawingColor = .systemYellow
        changeColorButton.setImage(UIImage(named: "colorOn"), for: .normal)

        drawState.currentPen = "yellowPen"
        editState.pencilButtonTouched()
        colorStack.isHidden = true
    }
    @IBAction func greenButton(_ sender: Any) {
        print("green button clicked")
        drawState.drawingColor = .systemGreen
        changeColorButton.setImage(UIImage(named: "colorOn"), for: .normal)
        drawState.currentPen = "greenPen"
        editState.pencilButtonTouched()
        colorStack.isHidden = true
    }
    @IBAction func blueButton(_ sender: Any) {
        print("blue button clicked")
        drawState.drawingColor = .systemBlue
        changeColorButton.setImage(UIImage(named: "colorOn"), for: .normal)
        drawState.currentPen = "bluePen"
        editState.pencilButtonTouched()
        colorStack.isHidden = true
    }
    
    @IBAction func colorSelectorButton(_ sender: Any) {
        editState.changeColor()
    }

    @IBAction func eraseButtonTouchUp(_ sender: Any) {
        editState.eraseButtonTouchUp()
        changeColorButton.setImage(UIImage(named: "colorOff"), for: .normal)
    }

    @IBAction func emojiButtonPressed(_ sender: Any) {
        print("emojiButtonPressed")
        editState.emojiButtonTouched()
        changeColorButton.setImage(UIImage(named: "colorOff"), for: .normal)
        //show view
    }

    @IBAction func menuButtonTouched(_ sender: Any) {
        editState.menuButtonTouched()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if let newVC = segue.destination as? EmojiViewController {
               emoji = newVC.selectedEmoji
               newVC.delegate = self
           }
    }

    func changeHiddenOfEditMode(){
        if menuButton.isHidden {
            distanceSlider.isHidden = false
            distanceValue.isHidden = false
            distanceLable.isHidden = false
            widthSlider.isHidden = false
            widthLabel.isHidden = false
            undo.isHidden = false
            redo.isHidden = false
            menuButton.isHidden = false
        } else {
            distanceSlider.isHidden = true
            distanceValue.isHidden = true
            distanceLable.isHidden = true
            changeColorButton.isHidden = true
            eraseButton.isHidden = true
            colorStack.isHidden = true
            widthSlider.isHidden = true
            widthLabel.isHidden = true
            undo.isHidden = true
            redo.isHidden = true
            menuButton.isHidden = true
            emojiButton.isHidden = true
            pencilButton.isHidden = true
        }
    }
    
    @IBAction func undoButton(_ sender: Any) {
        editState.undoErase()
    }
    
    @IBAction func redoButton(_ sender: Any) {
        editState.redoErase()
    }

    @IBAction func distanceSliderValueChange(_ sender: Any) {
        editState.distanceSliderChange()
    }

    @IBAction func distanceSliderTouchUpInside(_ sender: Any) {
        editState.removeSphere()
    }
    
    @IBAction func distanceSliderTouchUpOutside(_ sender: Any) {
        editState.removeSphere()
    }
    
    @IBAction func widthSliderValueChange(_ sender: Any) {
        editState.widthSliderChange()
    }

    @IBAction func widthSliderTouchUpInside(_ sender: Any) {
        editState.removeSphere()
    }

    @IBAction func widthSliderTouchUpOutside(_ sender: Any) {
        editState.removeSphere()
    }
    
    
    func createReferenceSphere() -> SCNNode {
        let sphere = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white
        sphere.materials = [material]
        let node = SCNNode(geometry: sphere)
        return node
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first{
            if touch.tapCount == 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    if !self.doubleTapHappened {
                        print("tap count is 1")
                        if !self.editState.eraserOn && !self.editState.EmojiOn {
                            self.drawState.touchesBegan(touches, with: event)
                        } else {
                            self.editState.touchesBegan(touches, with: event)
                        }
                    } else {
                        print("tap count is 2")
                        self.changeState()
                    }
                    self.doubleTapHappened = false
                }
            } else if touch.tapCount == 2 {
                doubleTapHappened = true
                print("touches began double tap")
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        //state.touchesMoved(touches, with: event)
        if !editState.eraserOn && !editState.EmojiOn {
            drawState.touchesMoved(touches, with: event)
        } else {
            editState.touchesMoved(touches, with: event)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
   //     state.touchesEnded(touches, with: event)
        if !editState.eraserOn {
            drawState.touchesEnded(touches, with: event)
        } else {
            editState.touchesEnded(touches, with: event)
        }
    }
    
    //MARK: - iOS override properties
    override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }

    override var prefersStatusBarHidden: Bool {
        return true;
    }
    

    func changeState() {
        if state == drawState {
            changeState(nextState: editState)
        }
        else {
            changeState(nextState: drawState)
        }
    }
    
}

// debug purposes
extension UIView {
    func subviewsRecursive() -> [UIView] {
        return subviews + subviews.flatMap { $0.subviewsRecursive() }
    }
}


class State : UIView {
    func enter() {
        // Override
    }
    
    func exit() {
        // Override
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Override
    }
     
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Override
    }
     
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Override
    }
}

extension HomeViewController : ChangeEmojiDelegate{
    func changeEmoji(emoji: Emoji){
        self.dismiss(animated: true)
        self.emoji = emoji
        editState.stateChangeEmoji(emoji: emoji)
        editState.emojiButton.activateButton(imageName: emoji.name)
        editState.menuButton.setImage(UIImage(named: emoji.name), for: .normal )
        print("home:", emoji.name)
    }
    func getUpdatedList() ->[Emoji] {
        return editState.getEmojiList()
    }
}
