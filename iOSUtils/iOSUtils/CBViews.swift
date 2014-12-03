//
//  BorderViews.swift
//  MobileMenu
//
//  Created by Wes Byrne on 10/22/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit





@IBDesignable class CBView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
}




@IBDesignable class CBShadowView: UIView {

    
    @IBInspectable var shadowColor: UIColor = UIColor.blackColor() {
        didSet { self.layer.shadowColor = shadowColor.CGColor }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet { self.layer.shadowRadius = shadowRadius }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet { self.layer.shadowOpacity = shadowOpacity }
    }
    @IBInspectable var shadowOffset: CGSize = CGSizeZero {
        didSet { self.layer.shadowOffset = shadowOffset }
    }
    
    @IBInspectable var shouldRasterize: Bool = false {
        didSet {
            self.layer.shouldRasterize = shouldRasterize
            self.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
    }
    
    @IBInspectable var useShadowPath: Bool = false
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = shadowColor.CGColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if useShadowPath {
            self.layer.shadowPath = UIBezierPath(rect: self.frame).CGPath
        }
    }
}











@IBDesignable class CBBorderView: UIView {
    
    @IBInspectable var topBorder: Bool = false
    @IBInspectable var bottomBorder: Bool = false
    @IBInspectable var leftBorder: Bool = false
    @IBInspectable var rightBorder: Bool = false
    
    @IBInspectable var leftInset: CGFloat = 0
    @IBInspectable var rightInset: CGFloat = 0
    @IBInspectable var topInset: CGFloat = 0
    @IBInspectable var bottomInset: CGFloat = 0
    
    @IBInspectable var borderWidth: CGFloat = 1
    @IBInspectable var borderColor: UIColor = UIColor.whiteColor()

    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var context = UIGraphicsGetCurrentContext();
        
        CGContextSetLineWidth(context, CGFloat(borderWidth));
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor)
        
        if topBorder == true {
            CGContextMoveToPoint(context, leftInset, 0);
            CGContextAddLineToPoint(context, self.bounds.size.width - rightInset, 0);
            CGContextStrokePath(context);
        }
        if leftBorder == true {
            CGContextMoveToPoint(context, 0, topInset);
            CGContextAddLineToPoint(context, 0, self.frame.size.height - bottomInset);
            CGContextStrokePath(context);
        }
        if rightBorder == true {
            CGContextMoveToPoint(context, self.frame.size.width, topInset);
            CGContextAddLineToPoint(context, self.bounds.size.width, self.frame.size.height - bottomInset);
            CGContextStrokePath(context);
        }
        if bottomBorder == true {
            CGContextMoveToPoint(context, leftInset, self.frame.size.height);
            CGContextAddLineToPoint(context, self.bounds.size.width - rightInset, self.frame.size.height);
            CGContextStrokePath(context);
        }
    }
}













