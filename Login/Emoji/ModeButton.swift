//
//  ModeButton.swift
//  Login
//
//  Created by Scarlett Fan on 4/15/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit

class ModeButton: UIButton {


        static var isOn = false

        override init(frame: CGRect) {
            super.init(frame: frame)
            initButton()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initButton()
        }

        func initButton() {
            setImage(UIImage(named: "emojiOff"), for: .normal)
            addTarget(self, action: #selector( ModeButton.buttonPressed), for: .touchUpInside)
        }

        @objc func buttonPressed() {
            if ModeButton.isOn{
                deactivateButton()
            } else{
                activateButton(imageName: "bandage")
            }
        }

    func activateButton(imageName: String) {
            ModeButton.isOn = true

            let title = "Emoji On"
            let image = UIImage(named: imageName)

            setTitle(title, for: .normal)
            setImage(image, for: .normal)
        }

    func deactivateButton(){
        ModeButton.isOn = false

        let title = "Emoji Off"
        let image = UIImage(named: "emojiOff")

        setTitle(title, for: .normal)
        setImage(image, for: .normal)

    }

    }

    class ChoiceButton : UIButton {
        override init(frame: CGRect) {
               super.init(frame: frame)
               initButton()
           }

           required init?(coder aDecoder: NSCoder) {
               super.init(coder: aDecoder)
               initButton()
           }

           func initButton() {
                setImage(UIImage(named: "emojiOff"), for: .normal)
           }
}
