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
    
    
    @IBAction func popButtonSelected(_ sender: CBButton) {
        sender.isSelected = !sender.isSelected
    }

    @IBAction func updateShrinkScale(_ sender: UISlider) {
        basicButton.shrinkscale = CGFloat(sender.value)
        popButton.shrinkscale = CGFloat(sender.value)
    }

    @IBAction func updateDamping(_ sender: UISlider) {
        basicButton.damping = CGFloat(sender.value)
        popButton.damping = CGFloat(sender.value)
        
    }
    
    @IBAction func adjustPopScale(_ sender: UIStepper) {
        popButton.popScale = CGFloat(sender.value)
        popScaleLabel.text = "\(sender.value)"
        popButton.popAnimation()
    }
    
    var randomize = false;
    var iconTypes : [CBIconType] = [.Hamburger, .Close, .Add, .AngleLeft, .AngleRight, .ArrowLeft, .ArrowRight];
    
    @IBAction func iconButtonSelected(_ sender: CBIconButton) {
        
        if randomize {
            let icon = sender.iconType
            var newIcon = sender.iconType
            while icon == newIcon {
                let rand = Int.random(low: 0, high: iconTypes.count - 1)
                newIcon = iconTypes[rand]
            }
            sender.setIcon(newIcon, animated: true)
            return
        }
        
        
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
            randomize = true
        }
    }
}
