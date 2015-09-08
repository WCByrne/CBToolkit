//
//  MenuButton.swift
//  MobileMenu
//
//  Created by Wes Byrne on 9/26/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable public class CBButtonView: UIControl {
    
    @IBInspectable public var bouncy: Bool = true
    @IBInspectable public var popWhenSelected: Bool = false
    
    @IBInspectable public var damping: CGFloat = 0.3
    
    @IBInspectable public var shrinkscale: CGFloat = 0.95
    @IBInspectable public var popScale: CGFloat = 1.2
    
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable public var circleCrop : Bool = false {
        didSet {
            self.layoutSubviews()
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable public var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    @IBInspectable public var tintSubviews: Bool = false {
        didSet {
            self.tintColorDidChange()
        }
    }
    
    private var popping = false
    
    override public var highlighted: Bool {
        didSet {
            if bouncy == true {
                if highlighted {
                    self.animateShrink()
                }
                else if !selected {
                    self.animateToResting()
                }
            }
        }
    }
    
    override public var selected: Bool {
        didSet {
            if bouncy {
                if selected {
                    if popWhenSelected {
                        self.popAnimation()
                    }
                    else {
                        self.animateToResting()
                    }
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            var sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        if tintSubviews {
            for view in self.subviews as! [UIView] {
                view.tintColor = self.tintColor
            }
        }
    }
    
    public override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.touchInside {
            self.selected = !self.selected
        }
        super.touchesEnded(touches, withEvent: event)
    }
    
    
    private func animateShrink() {
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.shrinkscale, self.shrinkscale)
            }, completion: nil)
    }
    
    
    private func animateToResting() {
        UIView.animateWithDuration(1, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    public func popAnimation() {
        UIView.animateWithDuration(0.26, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 0.3, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.popScale, self.popScale)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: 5, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
        }

    }
}





@IBDesignable public class CBButton: UIButton {
    
    @IBInspectable public var bouncy: Bool = true
    @IBInspectable public var popWhenSelected: Bool = false
    
    @IBInspectable public var damping: CGFloat = 0.3
    
    @IBInspectable public var shrinkscale: CGFloat = 0.9
    @IBInspectable public var popScale: CGFloat = 1.2
    
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable public var circleCrop : Bool = false {
        didSet {
            self.layoutSubviews()
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable public var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    override public var highlighted: Bool {
        didSet {
            if bouncy == true {
                if highlighted {
                    self.animateShrink()
                }
                else if !selected {
                    self.animateToResting()
                }
            }
        }
    }
    
    override public var selected: Bool {
        didSet {
            if bouncy {
                if selected {
                    if popWhenSelected {
                        self.popAnimation()
                    }
                    else {
                        self.animateToResting()
                    }
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            var sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    
    private func animateShrink() {
        UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.shrinkscale, self.shrinkscale)
            }, completion: nil)
    }
    
    
    private func animateToResting() {
        UIView.animateWithDuration(0.8, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: UIViewAnimationOptions.AllowUserInteraction | UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            self.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    public func popAnimation() {
        UIView.animateWithDuration(0.26, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: UIViewAnimationOptions.CurveEaseOut | UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
            self.transform = CGAffineTransformMakeScale(self.popScale, self.popScale)
            }) { (finished) -> Void in
                UIView.animateWithDuration(0.8, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveEaseInOut | UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                    self.transform = CGAffineTransformMakeScale(1, 1)
                    }, completion: nil)
        }
        
    }
}





