//
//  ViewCell.swift
//  CBApp
//
//  Created by Wes Byrne on 9/7/15.
//  Copyright (c) 2015 Type2Designs. All rights reserved.
//

import Foundation
import UIKit
import CBToolkit


class ViewCell : UICollectionViewCell {
    
    @IBOutlet weak var basicView: CBView!
    @IBOutlet weak var gradientview: CBGradientView!
    @IBOutlet weak var borderView: CBBorderView!
    

    
    @IBAction func updateCornerRadius(sender: UISlider) {
        basicView.cornerRadius = CGFloat(sender.value)
    }
    @IBAction func updateBorder(sender: UISlider) {
        basicView.borderWidth = CGFloat(sender.value)
        borderView.borderWidth = CGFloat(sender.value)
    }
    @IBAction func updateShadowRadius(sender: UISlider) {
         basicView.shadowRadius = CGFloat(sender.value)
    }
    @IBAction func updateShadowOpacity(sender: UISlider) {
        basicView.shadowOpacity = sender.value
    }
    
    @IBAction func updateGradientTop(sender: UISlider) {
        gradientview.topColor = UIColor(white: 0, alpha: CGFloat(sender.value))
    }
    @IBAction func updateGradientBottom(sender: UISlider) {
        gradientview.bottomColor = UIColor(white: 0, alpha: CGFloat(sender.value))
    }
    
    @IBAction func topBorder(sender: UISwitch) {
        borderView.topBorder = sender.on
    }
    @IBAction func bottomBorder(sender: UISwitch) {
        borderView.bottomBorder = sender.on
    }
    @IBAction func leftBorder(sender: UISwitch) {
        borderView.leftBorder = sender.on
    }
    @IBAction func rightBorder(sender: UISwitch) {
        borderView.rightBorder = sender.on
    }
}