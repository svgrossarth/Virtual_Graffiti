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


     if let window = UIApplication.shared.windows.last, let toolPicker = PKToolPicker.shared(for: window) {
        //toolpicker shows up
           toolPicker.setVisible(false, forFirstResponder: canvasView)
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
        if let tool = toolPicker.selectedTool as? PKInkingTool{
            let inverseColorRGB = tool.color.rgb()
            let inverseColor = UIColor(red: CGFloat(inverseColorRGB[0]), green: CGFloat(inverseColorRGB[1]), blue: CGFloat(inverseColorRGB[2]), alpha: CGFloat(inverseColorRGB[3]))
            makeColor.ChangeColor(newColor: inverseColor)
        }
        if let tool = toolPicker.selectedTool as? PKEraserTool {
            if let editState = self.pencilKitDelegate as? EditState {
                editState.eraserOn = true
            }
        } else {
            if let editState = self.pencilKitDelegate as? EditState {
                editState.eraserOn = false
            }
        }

        //print("Color gotten", tool!.color)
        //print("correct color: ", inverseColor)
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
          print("setting newColor to:", newColor)
          self.color = newColor
      }
    func getColor() -> UIColor {
        print("in the class: getColor()", self.color)
        return self.color
    }

}

extension UIColor {

    func rgb() -> [CGFloat] {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            
            let iRed = (Int(fRed * 255.0))
            let iGreen = (Int(fGreen * 255.0))
            let iBlue = (Int(fBlue * 255.0))
            _ = Int(fAlpha * 255.0)
            
            print("red ", iRed)
            print("blue ", iGreen)
            print("green ", iBlue)
            
            if iRed == iGreen && iGreen == iBlue {
                print("they are equal")
                let r = (255 - (CGFloat(fRed * 255.0)))/255
                let g = (255 - (CGFloat(fGreen * 255.0)))/255
                let b = (255 - (CGFloat(fBlue * 255.0)))/255
                let a = CGFloat(fAlpha * 255.0)/255
                
                let rgb = [r, g, b, a]
                return rgb
            } else {
                let r = (CGFloat(fRed * 255.0))/255
                let g = (CGFloat(fGreen * 255.0))/255
                let b = (CGFloat(fBlue * 255.0))/255
                let a = CGFloat(fAlpha * 255.0)/255
                
                let rgb = [r, g, b, a]
                return rgb
            }

            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).

        } else {
            // Could not extract RGBA components:
            return []
        }
    }
}

