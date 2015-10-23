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
    @IBAction func iconButtonSelected(sender: CBIconButton) {
        if (sender.iconType == .Hamburger) {
            sender.setIcon(CBIconType.Close, animated: true)
        }
        else if (sender.iconType == .Close) {
            sender.setIcon(CBIconType.Add, animated: true)
        }
        else if (sender.iconType == .Add) {
            sender.setIcon(CBIconType.AngleLeft, animated: true)
        }
        else if (sender.iconType == .AngleLeft) {
            sender.setIcon(CBIconType.AngleRight, animated: true)
        }
        else if (sender.iconType == .AngleRight) {
            sender.setIcon(CBIconType.ArrowLeft, animated: true)
        }
        else if (sender.iconType == .ArrowLeft) {
            sender.setIcon(CBIconType.ArrowRight, animated: true)
        }
        else {
            sender.setIcon(CBIconType.Hamburger, animated: true)
        }
    }
}