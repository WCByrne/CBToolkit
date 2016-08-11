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
    

    
    @IBAction func updateCornerRadius(_ sender: UISlider) {
        basicView.cornerRadius = CGFloat(sender.value)
    }
    @IBAction func updateBorder(_ sender: UISlider) {
        basicView.borderWidth = CGFloat(sender.value)
        borderView.borderWidth = CGFloat(sender.value)
    }
    @IBAction func updateShadowRadius(_ sender: UISlider) {
         basicView.shadowRadius = CGFloat(sender.value)
    }
    @IBAction func updateShadowOpacity(_ sender: UISlider) {
        basicView.shadowOpacity = sender.value
    }
    
    @IBAction func updateGradientTop(_ sender: UISlider) {
        gradientview.topColor = UIColor(white: 0, alpha: CGFloat(sender.value))
    }
    @IBAction func updateGradientBottom(_ sender: UISlider) {
        gradientview.bottomColor = UIColor(white: 0, alpha: CGFloat(sender.value))
    }
    
    @IBAction func topBorder(_ sender: UISwitch) {
        borderView.topBorder = sender.isOn
    }
    @IBAction func bottomBorder(_ sender: UISwitch) {
        borderView.bottomBorder = sender.isOn
    }
    @IBAction func leftBorder(_ sender: UISwitch) {
        borderView.leftBorder = sender.isOn
    }
    @IBAction func rightBorder(_ sender: UISwitch) {
        borderView.rightBorder = sender.isOn
    }
}
