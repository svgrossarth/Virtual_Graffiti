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
import CoreLocation
import SwiftUI

class HomeViewController: UIViewController {
    var drawState = DrawState()
    var editState = EditState()
    var state : State = State()
    var refSphere = SCNNode()
    var sphereCallbackCanceled = false
    var EmojiOn : Bool = false
    
    @IBOutlet weak var colorStack: UIStackView!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var orangeButton: UIButton!
    @IBOutlet weak var yellowButton: UIButton!
    @IBOutlet weak var greenButton: UIButton!
    @IBOutlet weak var blueButton: UIButton!
    
    @IBOutlet weak var eraseButton: UIButton!
    @IBOutlet weak var changeColorButton: UIButton!
    @IBOutlet weak var changeStateButton: UIButton!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!

    @IBOutlet weak var emojiButton: ModeButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(drawState)
        drawState.initialize(_sceneView: sceneView)
        
        state = drawState
        state.enter()
        sliderUISetup()
        view.addSubview(editState)
        editState.initialize(emojiButton: emojiButton, eraseButton: eraseButton, slider: slider, distanceValue: distanceValue, distanceLabel: distanceLable, drawState: drawState, refSphere: refSphere, sceneView: sceneView)
        editState.createColorSelector(changeColorButton: changeColorButton, colorStack: colorStack)
        
        view.bringSubviewToFront(changeStateButton)
         self.view.bringSubviewToFront(emojiButton)
    }
    
    func sliderUISetup () {
        slider.transform = CGAffineTransform(rotationAngle: .pi / -2)
        slider.minimumValue = 0.2
        slider.maximumValue = 2
        slider.value = 1
        distanceValue.text = String(format: "%.2f", slider.value)
        self.view.bringSubviewToFront(slider)
        self.view.bringSubviewToFront(distanceLable)
        self.view.bringSubviewToFront(distanceValue)
        self.view.bringSubviewToFront(changeColorButton)
        self.view.bringSubviewToFront(eraseButton)
        self.view.bringSubviewToFront(emojiButton)
        self.view.bringSubviewToFront(colorStack)
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
    
    @IBAction func redButton(_ sender: Any) {
        print("red button clicked")
        drawState.drawingColor = .systemRed
        changeColorButton.backgroundColor = .systemRed
    }
    @IBAction func orangeButton(_ sender: Any) {
        print("orange button clicked")
        drawState.drawingColor = .systemOrange
        changeColorButton.backgroundColor = .systemOrange
    }
    @IBAction func yellowButton(_ sender: Any) {
        print("yellow button clicked")
        drawState.drawingColor = .systemYellow
        changeColorButton.backgroundColor = .systemYellow
    }
    @IBAction func greenButton(_ sender: Any) {
        print("green button clicked")
        drawState.drawingColor = .systemGreen
        changeColorButton.backgroundColor = .systemGreen
    }
    @IBAction func blueButton(_ sender: Any) {
        print("blue button clicked")
        drawState.drawingColor = .systemBlue
        changeColorButton.backgroundColor = .systemBlue
    }
    
    @IBAction func colorSelectorButton(_ sender: Any) {
        editState.changeColor()
    }
    @IBAction func eraseButtonTouchUp(_ sender: Any) {
        editState.eraseButtonTouchUp()
    }

    @IBAction func emojiButtonPressed(_ sender: Any) {
        editState.emojiButtonTouched()
       }
    
    func changeHiddenOfEditMode(){
        if slider.isHidden {
            slider.isHidden = false
            distanceValue.isHidden = false
            distanceLable.isHidden = false
            changeColorButton.isHidden = false
            eraseButton.isHidden = false
            emojiButton.isHidden = false
        } else {
            slider.isHidden = true
            distanceValue.isHidden = true
            distanceLable.isHidden = true
            changeColorButton.isHidden = true
            eraseButton.isHidden = true
            emojiButton.isHidden = true
            colorStack.isHidden = true
        }
    }
    
    @IBAction func sliderValueChange(_ sender: Any) {
        editState.sliderValueChange()
    }
    

    @IBAction func sliderTouchUpInside(_ sender: Any) {
        editState.removeSphere()
    }
    
    @IBAction func sliderTouchUpOutside(_ sender: Any) {
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
        state.touchesBegan(touches, with: event)
   
    }
     
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        state.touchesMoved(touches, with: event)
    }
     
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        state.touchesEnded(touches, with: event)
    }
    
    //MARK: - iOS override properties
    override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }

    override var prefersStatusBarHidden: Bool {
        return true;
    }

    @IBAction func changeStateTouchUpInside(_ sender: Any) {
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

struct HomeViewController_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
