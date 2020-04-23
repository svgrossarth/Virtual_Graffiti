//
//  menuHeaderView.swift
//  Login
//
//  Created by Scarlett Fan on 4/21/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit

class MenuHeaderView: UICollectionReusableView {

    @IBOutlet weak var menuHeaderLabel: UILabel!
    var HeaderTitle: String! {
            didSet{
                HeaderTitle = "All Emoji"
                menuHeaderLabel.text = HeaderTitle
            }
        }
}
