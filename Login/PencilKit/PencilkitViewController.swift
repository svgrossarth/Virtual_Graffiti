//
//  PencilKitViewController.swift
//  ARsample
//
//  Created by Scarlett Fan on 1/31/20.
//  Copyright © 2020 Scarlett Fan. All rights reserved.
//

import UIKit
import PencilKit
import ARKit
import RealityKit

class PencilkitViewController: UIViewController {

    @IBOutlet weak var sceneView: ARView!
    var pencilKitCanvas =  PKCanvas()

    
    //MARK: - iOS Life Cycle
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        addPencilKit()

        sceneView.frame = view.frame
        view.addSubview(sceneView)
        let config =  ARWorldTrackingConfiguration()
//        sceneView.session.run(config)

//        let doubleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
//        doubleTap.numberOfTapsRequired = 2
//        sceneView.addGestureRecognizer(doubleTap)
//        doubleTap.delaysTouchesBegan = true

    }

//    @objc func handleDoubleTap() {
//        print("Double Tap!")
//    }
    
    override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          updateCanvasOrientation(with: view.bounds)
      }

    //MARK: - iOS override properties
    override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }

    override var prefersStatusBarHidden: Bool {
        return true;
    }

    //MARK: -  Setup Functions
   //3.
    private func addPencilKit() {
       view.backgroundColor = .clear
       pencilKitCanvas  = createPencilKitCanvas(frame: view.frame, delegate: self)
       view.addSubview(pencilKitCanvas)
    }
}
//2.
extension PencilkitViewController: PencilKitInterface { }

extension PencilkitViewController: PencilKitDelegate { }

