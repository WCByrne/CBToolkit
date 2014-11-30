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
    
    func validTouches(touches: NSSet) -> Bool {
        return CGRectContainsPoint(CGRectInset(self.bounds, -12, -12), touches.allObjects[0].locationInView(self))
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {

        if touches.count > 1 { return }
        
        if onTouchDownBlock != nil {
            onTouchDownBlock!(button: self)
        }
        if !shouldAnimate { return }
        animateShrink()
    }
    
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        if touches.count > 1 { return }
        
        if !validTouches(touches) {
            animateToResting()
            return
        }
        
        var shouldPop: Bool = false
        if onTouchUpBlock != nil {
            shouldPop = onTouchUpBlock!(button: self)
        }
        
        if shouldPop {
            popAnimation()
            return
        }
        
        if !shouldAnimate { return }
        animateToResting()
    }
    
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        if touches.count > 1 { return }
        if validTouches(touches) {
            animateShrink()
        }
        else {
            animateToResting()
        }
    }
    
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        println("touches cancelled")
        animateToResting()
    }
    
    
    private func animateShrink() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.shrinkscale, self.shrinkscale)
            }, completion: nil)
    }
    
    
    private func animateToResting() {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    
    func popAnimation() {
        
        UIView.animateWithDuration(0.26, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.popScale, self.popScale)
            }) { (finished) -> Void in
                self.shouldAnimate = true
                UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
        }

    }
}



