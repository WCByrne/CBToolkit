//
//  CBTextField.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/17/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable class CBTextField : UITextField {
    
    @IBInspectable var textInset: CGPoint = CGPointZero
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    
    @IBInspectable var bottomBorder: Bool = false {
        didSet {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clearColor().CGColor
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            if bottomBorder == false {
                self.layer.borderWidth = borderWidth
            }
        }
    }
    @IBInspectable var borderColor: UIColor! = UIColor(white: 0, alpha: 0.5) {
        didSet {
            if bottomBorder == false {
                self.layer.borderColor = borderColor.CGColor
            }
        }
    }
    
    @IBInspectable var placeholderColor: UIColor! = UIColor(white: 1, alpha: 1) {
        didSet {
            if (placeholder != nil) {
                attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName: placeholderColor, NSFontAttributeName : font])
            }
            self.setNeedsDisplay()
        }
    }
    
    override var placeholder: String? {
        didSet {
            if placeholder != nil {
                attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName: placeholderColor,
                    NSFontAttributeName : self.font])
            }
            self.setNeedsDisplay()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        
        if bottomBorder {
            self.layer.borderWidth = 0
        }
    }
    
    
    // Text inset
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textInset.x, textInset.y)
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, textInset.x, textInset.y)
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if (bottomBorder) {
            var context = UIGraphicsGetCurrentContext();
            
            CGContextSetLineWidth(context, borderWidth);
            CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
            
            CGContextMoveToPoint(context, 0, self.bounds.size.height);
            CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
            
            CGContextStrokePath(context);
        }
    }
}
