//
//  File.swift
//  Login
//
//  Created by Scarlett Fan on 4/22/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//

import UIKit

class RecentHeaderView : UICollectionReusableView {
    @IBOutlet weak var recentLabel : UILabel!
    var recentHeaderTitle : String!{
        didSet{
            recentLabel.text = recentHeaderTitle
        }
    }
}
