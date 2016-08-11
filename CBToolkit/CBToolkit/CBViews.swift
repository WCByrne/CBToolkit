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
    @IBInspectable public var borderColor: UIColor = UIColor.lightGray {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    
    /// The color of the view's shadow
    @IBInspectable public var shadowColor: UIColor = UIColor.black {
        didSet { self.layer.shadowColor = shadowColor.cgColor }
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
    @IBInspectable public var shadowOffset: CGSize = CGSize.zero {
        didSet { self.layer.shadowOffset = shadowOffset }
    }
    /// Rasterize the shadow accounting for screen scale. Can help with performace
    @IBInspectable public var shouldRasterize: Bool = false {
        didSet {
            self.layer.shouldRasterize = shouldRasterize
            self.layer.rasterizationScale = UIScreen.main.scale
        }
    }
    
    /// Render the shadow using the views frame. Can help with performace.
    @IBInspectable public var useShadowPath: Bool = false
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset = shadowOffset
        if shouldRasterize == true {
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = UIScreen.main.scale
        }
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
        if useShadowPath {
            let rect = self.bounds.offsetBy(dx: shadowOffset.width, dy: shadowOffset.height)
            self.layer.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRadius).cgPath
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
    @IBInspectable public var borderColor: UIColor = UIColor.white { didSet{ setNeedsDisplay() }}

    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext();
        
        context?.setLineWidth(borderWidth)
        context?.setStrokeColor(borderColor.cgColor)
        
        if topBorder == true {
            context?.moveTo(x: leftInset, y: 0)
            context?.addLineTo(x: self.bounds.size.width - rightInset, y: 0)
            context?.strokePath()
        }
        if leftBorder == true {
            context?.moveTo(x: 0, y: topInset)
            context?.addLineTo(x: 0, y: self.bounds.size.height - bottomInset)
            context?.strokePath()
        }
        if rightBorder == true {
            context?.moveTo(x: self.bounds.size.width, y: topInset)
            context?.addLineTo(x: self.bounds.size.width, y: self.bounds.size.height - bottomInset)
            context?.strokePath()
        }
        if bottomBorder == true {
            context?.moveTo(x: leftInset, y: self.bounds.size.height)
            context?.addLineTo(x: self.bounds.size.width - rightInset, y: self.bounds.size.height)
            context?.strokePath()
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
    @IBInspectable public var angle: CGFloat = 1   { didSet{ setNeedsDisplay() }}
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
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
        
        let mGradientColors = colors.map {(color: UIColor!) -> AnyObject! in return color.cgColor as AnyObject! } as NSArray
        let mGradient = CGGradient(colorsSpace: colorSpace, colors: mGradientColors, locations: locations);
        
        var mStartPoint = CGPoint(x: rect.midX, y: rect.minY);
        var mEndPoint = CGPoint(x: rect.midX, y: rect.maxY);
        
        if angle >= 90 {
            mStartPoint = CGPoint(x: rect.minX, y: rect.midY);
            mEndPoint = CGPoint(x: rect.maxX, y: rect.midY);
        }
        
        context!.saveGState();
        context!.addRect(rect);
        context!.clip();
        context!.drawLinearGradient(mGradient!, start: mStartPoint, end: mEndPoint, options: CGGradientDrawingOptions(rawValue: 0))
        context!.restoreGState();
    }
}
