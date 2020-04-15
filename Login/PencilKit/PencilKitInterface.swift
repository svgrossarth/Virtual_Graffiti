//
//  PencilKitInterface.swift
//  ARsample
//
//  Created by Scarlett Fan on 1/31/20.
//  Copyright © 2020 Scarlett Fan. All rights reserved.
//

import UIKit
import PencilKit
import ARKit

protocol PencilKitDelegate: class {
    func snapshot(from canvas: PKCanvas) -> UIImage
}

extension PencilKitDelegate {
    func snapshot(from canvas: PKCanvas) -> UIImage {
        //Take PencilKit Drawings snapshot
        return UIImage()
    }
}

protocol PencilKitInterface: NSObject {
    var pencilKitCanvas: PKCanvas { get set }
    func createPencilKitCanvas(frame: CGRect, delegate: PencilKitDelegate) -> PKCanvas
    func updateCanvasOrientation(with frame: CGRect)
}

extension PencilKitInterface {
    func createPencilKitCanvas(frame: CGRect, delegate: PencilKitDelegate) -> PKCanvas {
      //1. Assign PKCanvas to our interface property
      pencilKitCanvas = PKCanvas(frame: frame)
      //2. Connect the delegates
      pencilKitCanvas.pencilKitDelegate = delegate
      return pencilKitCanvas
    }

    func updateCanvasOrientation(with frame: CGRect) {
        //2. Update Orientation frame.
        pencilKitCanvas.updateCanvasOrientation(with: frame)
    }
}
