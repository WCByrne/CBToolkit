//
//  ButtonCell.swift
//  CBApp
//
//  Created by Wes Byrne on 9/7/15.
//  Copyright (c) 2015 Type2Designs. All rights reserved.
//

import Foundation
import UIKit
import CBToolkit


class ButtonCell : UICollectionViewCell {
    
    @IBOutlet weak var basicButton: CBButton!
    @IBOutlet weak var popButton: CBButton!
    @IBOutlet weak var popScaleLabel: UILabel!
    
    
    @IBAction func popButtonSelected(sender: CBButton) {
        sender.selected = !sender.selected
    }

    @IBAction func updateShrinkScale(sender: UISlider) {
        basicButton.shrinkscale = CGFloat(sender.value)
        popButton.shrinkscale = CGFloat(sender.value)
    }

    @IBAction func updateDamping(sender: UISlider) {
        basicButton.damping = CGFloat(sender.value)
        popButton.damping = CGFloat(sender.value)
        
    }
    
    @IBAction func adjustPopScale(sender: UIStepper) {
        popButton.popScale = CGFloat(sender.value)
        popScaleLabel.text = "\(sender.value)"
        popButton.popAnimation()
    }
}