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
    
    @IBOutlet weak var changeStateButton: UIButton!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(editState)
        editState.initialize()
        view.addSubview(drawState)
        drawState.initialize(_sceneView: sceneView)
        
        state = drawState
        state.enter()
        
        view.bringSubviewToFront(changeStateButton)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        state.exit()
    }
    
    
    func changeState(nextState : State) {
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
