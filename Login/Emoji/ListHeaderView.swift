//
//  ListHeaderView.swift
//  Login
//
//  Created by Scarlett Fan on 4/22/20.
//  Copyright © 2020 Team Rocket. All rights reserved.
//


import UIKit

class ListHeaderView : UICollectionReusableView {
    @IBOutlet weak var listLabel : UILabel!
    var listHeaderTitle : String!{
        didSet{
            listLabel.text = listHeaderTitle
        }
    }
}
