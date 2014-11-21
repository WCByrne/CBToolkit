//
//  MenuButton.swift
//  MobileMenu
//
//  Created by Wes Byrne on 9/26/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit



// Return yes to perform a pop animation before returning to normal state
typealias BouncyButtonActionBlock = (button: BouncyButtonView) -> Bool

@IBDesignable class BouncyButtonView: UIView {

    var onTouchUpBlock: BouncyButtonActionBlock?
    var onTouchDownBlock: BouncyButtonActionBlock?
    
    @IBInspectable var shouldAnimate: Bool = true
    
    @IBInspectable var shrinkscale: CGFloat = 0.9
    @IBInspectable var popScale: CGFloat = 1.2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        if onTouchDownBlock != nil {
            onTouchDownBlock!(button: self)
        }
        
        if !shouldAnimate { return }
        
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(CGFloat(self.shrinkscale), CGFloat(self.shrinkscale))
        }, completion: nil)
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        
        var shouldPop: Bool = false
        if onTouchUpBlock != nil {
            shouldPop = onTouchUpBlock!(button: self)
        }
        
        if shouldPop {
            popAnimation()
            return
        }
        
        if !shouldAnimate { return }
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    
    
    func popAnimation() {
        
        UIView.animateWithDuration(0.23, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.popScale, self.popScale)
            }) { (finished) -> Void in
                self.shouldAnimate = true
                UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
        }
    }
}



