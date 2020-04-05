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
    
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(editState)
        editState.initialize()
        view.addSubview(drawState)
        drawState.initialize(_sceneView: sceneView)
        
        state = drawState
        state.enter()
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
