//
//  CBTextViews.swift
//  CBToolkit
//
//  Created by Wes Byrne on 11/30/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit




@IBDesignable public class CBTextView: UITextView {
    
    @IBInspectable public var autoExpand: Bool  = false {
        didSet {
            if autoExpand {
                if heightConstraint == nil {
                    heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: minimumHeight)
                    self.addConstraint(heightConstraint!)
                    self.layoutIfNeeded()
                }
            }
            else if heightConstraint != nil {
                self.removeConstraint(self.heightConstraint!)
                self.heightConstraint = nil
            }
        }
    }
    @IBInspectable public var minimumHeight: CGFloat = 35 {
        
        
        didSet {
            self.textDidChange()
        }
    }
    @IBInspectable public var maximumHeight: CGFloat = 100
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable public var borderColor: UIColor = UIColor.clearColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    
    @IBInspectable public var placeholderColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            if self.text == placeholder {
                self.textColor = placeholderColor
            }
        }
    }
    
    @IBInspectable public var normalTextColor: UIColor = UIColor.darkGrayColor() {
        didSet {
            if self.text != placeholder {
                self.textColor = normalTextColor
            }
        }
    }
    
    @IBInspectable public var placeholder: String = "" {
        didSet {
            if self.text.isEmpty {
                self.text = placeholder
                self.textColor = placeholderColor
            }
        }
    }
    
    public var heightConstraint: NSLayoutConstraint?
    public var currentText: String! {
        get {
            if self.text == self.placeholder {
                return ""
            }
            return self.text
        }
    }
    
    
    
    /********************************************************************************
    / Initialization
    ********************************************************************************/
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange", name: UITextViewTextDidChangeNotification, object: self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBeginEditing", name: UITextViewTextDidBeginEditingNotification, object: self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEndEditing", name: UITextViewTextDidEndEditingNotification, object: self)
            
            if self.text.isEmpty {
                self.text = placeholder
                self.textColor = placeholderColor
            }
            else {
                self.textColor = normalTextColor
            }
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.textDidChange()
        }
    }
    
    
    
     public func didBeginEditing() {
        if self.text == placeholder {
            self.text = ""
        }
        self.textColor = normalTextColor
    }
    
    
     public func didEndEditing() {
        if self.text.isEmpty {
            self.text = placeholder
            self.textColor = placeholderColor
        }
    }
    
     public func textDidChange() {
        
        var size = self.contentSize
        
        if self.text.isEmpty && !self.isFirstResponder() {
            self.text = placeholder
        }
        
        if text == placeholder {
            self.textColor = self.placeholderColor
        }
        else {
            self.textColor = self.normalTextColor
        }
        
        if !autoExpand || self.heightConstraint == nil { return }
        
        if size.height >= maximumHeight {
            heightConstraint!.constant = maximumHeight
        }
        else if size.height <= minimumHeight {
            heightConstraint?.constant = minimumHeight
        }
        else {
            heightConstraint?.constant = size.height
        }
        
        self.layoutIfNeeded()
        self.superview?.layoutIfNeeded()
    }
    
}