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
import PencilKit
import CoreLocation


class HomeViewController: UIViewController {
    var drawState = DrawState()
    var editState = EditState()
    var state : State = State()
    var refSphere = SCNNode()
    var sphereCallbackCanceled = false
    
    @IBOutlet weak var changeStateButton: UIButton!
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(drawState)
        drawState.initialize(_sceneView: sceneView)
        
        state = drawState
        state.enter()
        sliderUISetup()
        view.addSubview(editState)
        editState.initialize(slider: slider, distanceValue: distanceValue, distanceLabel: distanceLable, drawState: drawState, refSphere: refSphere)
        
        view.bringSubviewToFront(changeStateButton)
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
    
    func changeHiddenOfEditMode(){
        if slider.isHidden {
            slider.isHidden = false
            distanceValue.isHidden = false
            distanceLable.isHidden = false
        } else {
            slider.isHidden = true
            distanceValue.isHidden = true
            distanceLable.isHidden = true
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
