//
//  PKCanvas.swift
//  ARsample
//
//  Created by Scarlett Fan on 1/31/20.
//  Copyright © 2020 Scarlett Fan. All rights reserved.
//
import UIKit
import PencilKit

//MARK: Global:
var makeColor = MakeColor(selectedColor: .blue)

class PKCanvas: UIView {

    var canvasView: PKCanvasView!
    weak var pencilKitDelegate: PencilKitDelegate?

    //MARK: - iOS Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPencilKitCanvas()
    }

    private func setupPencilKitCanvas() {
        canvasView = PKCanvasView(frame:self.bounds)
        canvasView.delegate = self
        canvasView.alwaysBounceVertical = false
        canvasView.allowsFingerDrawing = true
        canvasView.becomeFirstResponder()
        addSubview(canvasView)


     if let window = UIApplication.shared.windows.first, let toolPicker = PKToolPicker.shared(for: window) {
        //toolpicker shows up
           toolPicker.setVisible(true, forFirstResponder: canvasView)
           toolPicker.addObserver(canvasView)
           toolPicker.addObserver(self)

           canvasView.becomeFirstResponder()
        }
     }

    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func updateCanvasUI(frame: CGRect) {
       //2. Update PencilKit Orientation
    }

    func updateCanvasOrientation(with frame: CGRect){
        //1. assign updated frame to canvas
        self.canvasView.frame = frame
       //2.assign updated frame to self view
       self.frame = frame
    }
    func sendColor() -> UIColor {
        return makeColor.getColor()
    }

}


// MARK: Canvas View Delegate
extension PKCanvas: PKCanvasViewDelegate {

    /// Delegate method: Note that the drawing has changed.
    func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
        print("canvasViewDrawingDidChange")
    }
}


extension PKCanvas: PKToolPickerObserver {

    func toolPickerSelectedToolDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerSelectedToolDidChange")
        let tool = toolPicker.selectedTool as? PKInkingTool
        makeColor.ChangeColor(newColor: tool!.color)
    }

    func toolPickerIsRulerActiveDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerIsRulerActiveDidChange")
    }

    func toolPickerVisibilityDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerVisibilityDidChange")
    }

    func toolPickerFramesObscuredDidChange(_ toolPicker: PKToolPicker) {
        print("toolPickerFramesObscuredDidChange")
    }
}

class MakeColor{
    var color : UIColor

    init(selectedColor: UIColor) {
        print("========================= new class =========================")
        self.color = selectedColor
    }
    func ChangeColor(newColor: UIColor){
          self.color = newColor
      }
    func getColor() -> UIColor {
        return self.color
    }

}
