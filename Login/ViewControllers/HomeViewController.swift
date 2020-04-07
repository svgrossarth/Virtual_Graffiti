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
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var distanceValue: UILabel!
    @IBOutlet weak var distanceLable: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(editState)
        editState.initialize()
        view.addSubview(drawState)
        drawState.initialize(_sceneView: sceneView)
        
        state = drawState
        state.enter()
        slider.transform = CGAffineTransform(rotationAngle: .pi / -2)
        slider.minimumValue = 0.2
        slider.maximumValue = 2
        slider.value = 1
        distanceValue.text = String(format: "%.2f", slider.value)
        self.view.bringSubviewToFront(slider)
        self.view.bringSubviewToFront(distanceLable)
        self.view.bringSubviewToFront(distanceValue)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        state.exit()
    }
    
    
    func changeState(nextState : State) {
        state.exit()
        state = nextState
        state.enter()
    }
    
    @IBAction func sliderValueChange(_ sender: Any) {
        let defaultDistance : Float = 1
        if(slider.value > 1){
            drawState.distance = defaultDistance * powf(slider.value, 2)
            print("multiplier ", powf(slider.value, 2))
        } else {
           drawState.distance = defaultDistance * slider.value
            print("multiplier ", slider.value)
        }
        distanceValue.text = String(format: "%.2f", drawState.distance)
        print(drawState.distance)
        
        
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
}
