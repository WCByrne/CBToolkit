//
//  MenuButton.swift
//  MobileMenu
//
//  Created by Wes Byrne on 9/26/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit

/// A fully customizable view that allows button type interactions
@IBDesignable public class CBButtonView: UIControl {
    
    /// If the button view should bouncy in response to touches
    @IBInspectable public var bouncy: Bool = true
    /// If the button view should run the pop animation when selected
    @IBInspectable public var popWhenSelected: Bool = false
    /// The spring damping to apply to the bounce animation
    @IBInspectable public var damping: CGFloat = 0.3
    /// The scale transform to apply when the button view is highlighted
    @IBInspectable public var shrinkscale: CGFloat = 0.95
    /// The scale transform to apply for the pop animation
    @IBInspectable public var popScale: CGFloat = 1.2
    
    /// The layer corner radius
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    /// Crop the views layer to a circle
    @IBInspectable public var circleCrop : Bool = false {
        didSet { self.layoutSubviews() }
    }
    /// The border width of the views layer
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    /// The border color of the views layer
    @IBInspectable public var borderColor: UIColor = UIColor.lightGray {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    
    /// Force the views subviews to update their tint color the recievers tint color
    @IBInspectable public var tintSubviews: Bool = false { didSet { self.tintColorDidChange() }}
    
    private var popping = false
    
    override public var isHighlighted: Bool {
        didSet {
            if bouncy == true {
                if isHighlighted { self.animateShrink() }
                else if !isSelected { self.animateToResting() }
            }
        }
    }
    
    override public var isSelected: Bool {
        didSet {
            if bouncy {
                if isSelected {
                    if popWhenSelected { self.popAnimation() }
                    else { self.animateToResting() }
                }
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        if tintSubviews {
            for view in self.subviews {
                view.tintColor = self.tintColor
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.isTouchInside {
            self.isSelected = !self.isSelected
        }
        super.touchesEnded(touches, with: event)
    }
    
    
    private func animateShrink() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: self.shrinkscale, y: self.shrinkscale)
            }, completion: nil)
    }
    
    private func animateToResting() {
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: [UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    public func popAnimation() {
        UIView.animate(withDuration: 0.26, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: self.popScale, y: self.popScale)
            }) { (finished) -> Void in
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: 5, options: [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: nil)
        }
    }
}




/// A stylish bouncy UIButton
@IBDesignable public class CBButton: UIButton {
    
    /// If the button view should bouncy in response to touches
    @IBInspectable public var bouncy: Bool = true
    /// If the button view should run the pop animation when selected
    @IBInspectable public var popWhenSelected: Bool = false
    /// The spring damping to apply to the bounce animation
    @IBInspectable public var damping: CGFloat = 0.3
    /// The scale transform to apply when the button view is highlighted
    @IBInspectable public var shrinkscale: CGFloat = 0.9
    /// The scale transform to apply for the pop animation
    @IBInspectable public var popScale: CGFloat = 1.2
    
    /// The layer corner radius
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    /// Crop the views layer to a circle
    @IBInspectable public var circleCrop : Bool = false {
        didSet { self.layoutSubviews() }
    }
    /// The border width of the views layer
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    /// The border color of the views layer
    @IBInspectable public var borderColor: UIColor = UIColor.lightGray {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    
    override public var isHighlighted: Bool {
        didSet {
            if bouncy == true {
                if isHighlighted {
                    self.animateShrink()
                }
                else if !isSelected {
                    self.animateToResting()
                }
            }
        }
    }
    
    override public var isSelected: Bool {
        didSet {
            if bouncy {
                if isSelected {
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
    
//    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesBegan(touches, withEvent: event)
//        self.animateShrink()
//    }
//    
//    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
//        super.touchesEnded(touches, withEvent: event)
//        self.animateToResting()
//    }
//    
//    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
//        super.touchesCancelled(touches, withEvent: event)
//        self.animateToResting()
//    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    
    private func animateShrink() {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: [UIViewAnimationOptions.allowUserInteraction, UIViewAnimationOptions.beginFromCurrentState], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: self.shrinkscale, y: self.shrinkscale)
            }, completion: nil)
    }
    
    
    private func animateToResting() {
        UIView.animate(withDuration: 0.8, delay: 0.1, usingSpringWithDamping: damping, initialSpringVelocity: 4, options: [UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransform.identity
            }, completion: nil)
    }
    
    public func popAnimation() {
        UIView.animate(withDuration: 0.26, delay: 0.15, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: self.popScale, y: self.popScale)
            }) { (finished) -> Void in
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: self.damping, initialSpringVelocity: 5, options: [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
                    self.transform = CGAffineTransform(scaleX: 1, y: 1)
                    }, completion: nil)
        }
    }
}





