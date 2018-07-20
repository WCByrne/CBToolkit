//
//  CBTextField.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/17/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


/// Add some style to your labels
@IBDesignable public class CBLabel : UILabel {
    
    /// The corner radius of the label
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    /// Automatically set the corner radius to shortSide/2
    @IBInspectable public var circleCrop : Bool = false {
        didSet {
            self.layoutSubviews()
        }
    }
    /// The width of the labels border
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    /// The color of the labels border
    @IBInspectable public var borderColor: UIColor = UIColor.lightGray {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    
    /// The color of the labels shadow
    @IBInspectable public var layerShadowColor: UIColor = UIColor.black {
        didSet { self.layer.shadowColor = layerShadowColor.cgColor }
    }
    /// The blur radius of the labels shadow
    @IBInspectable public var layerShadowRadius: CGFloat = 0 {
        didSet { self.layer.shadowRadius = layerShadowRadius }
    }
    /// The opacity of the labels shadow
    @IBInspectable public var layerShadowOpacity: Float = 0 {
        didSet { self.layer.shadowOpacity = layerShadowOpacity }
    }
    /// The offset of the labels shadow
    @IBInspectable public var layerShadowOffset: CGSize = CGSize.zero {
        didSet { self.layer.shadowOffset = layerShadowOffset }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    /// Inherit the labels tintColor
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

/// Style your text views without a single line. Make your fields stand out right in the storyboard.
@IBDesignable public class CBTextField : UITextField {
    
    /// Inset the text from the text fields frame
    @IBInspectable public var textInset: CGPoint = CGPoint.zero
    /// Hide the caret
    @IBInspectable public var hideCaret: Bool = false
    /// The corner radius of the view
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    /// Draw a border along the bottom edge of the view. This will disable the full border.
    @IBInspectable public var bottomBorder: Bool = false {
        didSet {
            self.layer.borderWidth = 0
            self.layer.borderColor = UIColor.clear.cgColor
        }
    }
    /// The border width for the text fields. If bottomBorder is true, this only applies to the bottom.
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet {
            if bottomBorder == false {
                self.layer.borderWidth = borderWidth
            }
        }
    }
    /// The color of the text fields border.
    @IBInspectable public var borderColor: UIColor! = UIColor(white: 0, alpha: 0.5) {
        didSet {
            if bottomBorder == false {
                self.layer.borderColor = borderColor.cgColor
            }
        }
    }
    /// The color of the placeholder text
    @IBInspectable public var placeholderColor: UIColor! = UIColor(white: 1, alpha: 1) {
        didSet {
            if (placeholder != nil) {
                let attrs: [NSAttributedString.Key:AnyObject]  = [NSAttributedString.Key.foregroundColor: self.placeholderColor, NSAttributedString.Key.font : self.font!]
                attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: attrs)
            }
            self.setNeedsDisplay()
        }
    }
    override public var placeholder: String? {
        didSet {
            if placeholder != nil {
                attributedPlaceholder = NSAttributedString(string: placeholder!, attributes: [NSAttributedString.Key.foregroundColor: placeholderColor,
                    NSAttributedString.Key.font : self.font!])
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
    
    public override func caretRect(for position: UITextPosition) -> CGRect {
        if (hideCaret) { return CGRect.zero }
        return super.caretRect(for: position)
    }
    
    
    // Text inset
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: textInset.x, dy: textInset.y)
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: textInset.x, dy: textInset.y)
    }
    
    override public func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if (bottomBorder) {
            let context = UIGraphicsGetCurrentContext();
            
            context!.setLineWidth(borderWidth);
            context!.setStrokeColor(borderColor.cgColor)
            
            context!.move(to: CGPoint(x: 0, y: self.bounds.size.height))
            context!.addLine(to: CGPoint(x: self.bounds.size.width, y: self.bounds.size.height))
            
            context!.strokePath();
        }
    }
}
