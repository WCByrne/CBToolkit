//
//  CBTextField.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/17/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable public class CBLabel : UILabel {
    
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
    
    @IBInspectable public var layerShadowColor: UIColor = UIColor.blackColor() {
        didSet { self.layer.shadowColor = layerShadowColor.CGColor }
    }
    @IBInspectable public var layerShadowRadius: CGFloat = 0 {
        didSet { self.layer.shadowRadius = layerShadowRadius }
    }
    @IBInspectable public var layerShadowOpacity: Float = 0 {
        didSet { self.layer.shadowOpacity = layerShadowOpacity }
    }
    @IBInspectable public var layerShadowOffset: CGSize = CGSizeZero {
        didSet { self.layer.shadowOffset = layerShadowOffset }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    
    @IBInspectable public var tint : Bool = false {
        didSet {
            if tint {
                self.textColor = self.tintColor
            }
        }
    }
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        self.textColor = self.tintColor
    }
    
}


@IBDesignable public class CBTextField : UITextField {
    
    @IBInspectable public var textInset: CGPoint = CGPointZero
    @IBInspectable public var hideCaret: Bool = false
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    
    @IBInspectable public var bottomBorder: Bool = false {
        didSet {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            if bottomBorder == false {
                self.layer.borderWidth = borderWidth
            }
        }
    }
    @IBInspectable public var borderColor: UIColor! = UIColor(white: 0, alpha: 0.5) {
        didSet {
            if bottomBorder == false {
                self.layer.borderColor = borderColor.CGColor
            }
        }
    }
    
    @IBInspectable public var placeholderColor: UIColor! = UIColor(white: 1, alpha: 1) {
        didSet {
            if (placeholder != nil) {
                let attrs: [String:AnyObject]  = [NSForegroundColorAttributeName: self.placeholderColor, NSFontAttributeName : self.font!]
                attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: attrs)
            }
            self.setNeedsDisplay()
        }
    }
    
    override public var placeholder: String? {
        didSet {
            if placeholder != nil {
                attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName: placeholderColor,
                    NSFontAttributeName : self.font!])
            }
            self.setNeedsDisplay()
        }
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        
        if bottomBorder {
            self.layer.borderWidth = 0
        }
    }
    
        
    override public func caretRectForPosition(position: UITextPosition) -> CGRect {
        if (hideCaret) { return CGRectZero }
        return super.caretRectForPosition(position)
    }
    
    
    // Text inset
    override public func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textInset.x, textInset.y)
    }
    
    override public func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textInset.x, textInset.y)
    }
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if (bottomBorder) {
            let context = UIGraphicsGetCurrentContext();
            
            CGContextSetLineWidth(context, borderWidth);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            
            CGContextMoveToPoint(context, 0, self.bounds.size.height);
            CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
            
            CGContextStrokePath(context);
        }
    }
}
