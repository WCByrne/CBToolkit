//
//  CBViews.swift
//  CBToolkit
//
//  Created by Wes Byrne on 10/22/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit



/// CBView
@IBDesignable public class CBView: UIView {
    
    /// The corner radius
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    /// Keep the corner radius equal to shortSide/2
    @IBInspectable public var circleCrop : Bool = false {
        didSet { self.layoutSubviews() }
    }
    
    /// The border width
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    /// The border color
    @IBInspectable public var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    /// The color of the view's shadow
    @IBInspectable public var shadowColor: UIColor = UIColor.blackColor() {
        didSet { self.layer.shadowColor = shadowColor.CGColor }
    }
    /// The shadow radius
    @IBInspectable public var shadowRadius: CGFloat = 0 {
        didSet { self.layer.shadowRadius = shadowRadius }
    }
    /// The shadow opacity (0-1)
    @IBInspectable public var shadowOpacity: Float = 0 {
        didSet { self.layer.shadowOpacity = shadowOpacity }
    }
    /// <#Description#>
    @IBInspectable public var shadowOffset: CGSize = CGSizeZero {
        didSet { self.layer.shadowOffset = shadowOffset }
    }
    /// Rasterize the shadow accounting for screen scale. Can help with performace
    @IBInspectable public var shouldRasterize: Bool = false {
        didSet {
            self.layer.shouldRasterize = shouldRasterize
            self.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
    }
    
    /// Render the shadow using the views frame. Can help with performace.
    @IBInspectable public var useShadowPath: Bool = false
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = shadowColor.CGColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        if shouldRasterize == true {
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.mainScreen().scale
        }
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
        if useShadowPath {
            let rect = CGRectOffset(self.bounds, shadowOffset.width, shadowOffset.height)
            self.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRadius).CGPath
        }
    }
}

/// Draw borders on each side of the view individually
@IBDesignable public class CBBorderView: UIView {
    
    /// Draw a border along the top edge (with left and right insets)
    @IBInspectable public var topBorder: Bool = false { didSet{ setNeedsDisplay() }}
    /// Draw a border along the bottom edge (with left and right insets)
    @IBInspectable public var bottomBorder: Bool = false { didSet{ setNeedsDisplay() }}
    /// Draw a border along the left edge (with left and right insets)
    @IBInspectable public var leftBorder: Bool = false { didSet{ setNeedsDisplay() }}
    /// Draw a border along the right edge (with left and right insets)
    @IBInspectable public var rightBorder: Bool = false { didSet{ setNeedsDisplay() }}
    
    /// Inset the top and bottom borders from the left
    @IBInspectable public var leftInset: CGFloat = 0 { didSet{ setNeedsDisplay() }}
    /// Inset the top and bottom borders from the right
    @IBInspectable public var rightInset: CGFloat = 0 { didSet{ setNeedsDisplay() }}
    /// Inset the left and right borders from the top
    @IBInspectable public var topInset: CGFloat = 0 { didSet{ setNeedsDisplay() }}
    /// Inset the left and right borders from the bottom
    @IBInspectable public var bottomInset: CGFloat = 0 { didSet{ setNeedsDisplay() }}
    
    /// The width of all the borders to be drawn
    @IBInspectable public var borderWidth: CGFloat = 1 { didSet{ setNeedsDisplay() }}
    /// The color of all the borders to be drawn
    @IBInspectable public var borderColor: UIColor = UIColor.whiteColor() { didSet{ setNeedsDisplay() }}

    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext();
        
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




/// Render a gradient with three stages each with individual colors and placement
@IBDesignable public class CBGradientView: CBBorderView {
    
    /// The starting color of the gradient
    @IBInspectable public var topColor: UIColor! = UIColor(white: 0, alpha: 1) { didSet{ setNeedsDisplay() }}
    /// The middle color of the gradient (optional)
    @IBInspectable public var middleColor: UIColor? { didSet{ setNeedsDisplay() }}
    /// the end color of the gradient
    @IBInspectable public var bottomColor: UIColor! = UIColor(white: 0.2, alpha: 1) { didSet{ setNeedsDisplay() }}
    
    /// The position to start topColor (0-1)
    @IBInspectable public var topLocation: CGFloat = 0      { didSet{ setNeedsDisplay() }}
    /// The position of middleColor (0-1)
    @IBInspectable public var middleLocation: CGFloat = 0.5 { didSet{ setNeedsDisplay() }}
    /// The position of bottomColor (0-1)
    @IBInspectable public var bottomLocation: CGFloat = 1   { didSet{ setNeedsDisplay() }}
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let context = UIGraphicsGetCurrentContext();
        
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        var locations: [CGFloat]!
        var colors: [UIColor]!
        
        if (middleColor == nil) {
            locations = [topLocation, bottomLocation];
            colors = [topColor, bottomColor];
        }
        else {
            locations = [topLocation, middleLocation, bottomLocation];
            colors = [topColor, middleColor!, bottomColor];
        }
        
        let mGradientColors = colors.map {(color: UIColor!) -> AnyObject! in return color.CGColor as AnyObject! } as NSArray
        let mGradient = CGGradientCreateWithColors(colorSpace, mGradientColors, locations);
        
        let mStartPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        let mEndPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextSaveGState(context);
        CGContextAddRect(context, rect);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, mGradient, mStartPoint, mEndPoint, CGGradientDrawingOptions(rawValue: 0))
        CGContextRestoreGState(context);
    }
}

