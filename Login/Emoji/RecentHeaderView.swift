//
//  RecnetHeaderView.swift
//  Login
//
//  Created by Scarlett Fan on 4/21/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit

class RecentHeaderView: UICollectionReusableView {
    @IBOutlet weak var recentHeaderLabel: UILabel!
    var recentHeaderTitle: String! {
        didSet{
            recentHeaderLabel.text = recentHeaderTitle
        }
    }
}
