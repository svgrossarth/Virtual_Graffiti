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
        let Blue = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)

        override init(frame: CGRect) {
            super.init(frame: frame)
            initButton()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            initButton()
        }

        func initButton() {
            setTitleColor( Blue, for: .normal)
            addTarget(self, action: #selector( ModeButton.buttonPressed), for: .touchUpInside)
        }

        @objc func buttonPressed() {
            activateButton(bool: !ModeButton.isOn)
        }

        func activateButton(bool: Bool) {

            ModeButton.isOn = bool

            let color = bool ?  Blue : .clear
            let title = bool ? "Emoji On" : "Emoji Off"
            let titleColor = bool ? .white :  Blue

            setTitle(title, for: .normal)
            setTitleColor(titleColor, for: .normal)
            backgroundColor = color
        }

    }

    class ChoiceButton : UIButton {
        let Blue = UIColor(red: 29.0/255.0, green: 161.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        override init(frame: CGRect) {
               super.init(frame: frame)
               initButton()
           }

           required init?(coder aDecoder: NSCoder) {
               super.init(coder: aDecoder)
               initButton()
           }

           func initButton() {
                setTitleColor(Blue, for: .normal)
           }
}
