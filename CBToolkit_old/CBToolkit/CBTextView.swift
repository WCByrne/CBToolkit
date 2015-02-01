//
//  CBTextViews.swift
//  CBToolkit
//
//  Created by Wes Byrne on 11/30/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit




@IBDesignable class CBTextView: UITextView {
    
    @IBInspectable var autoExpand: Bool  = false {
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
    @IBInspectable var minimumHeight: CGFloat = 35 {
        didSet {
            self.textDidChange()
        }
    }
    @IBInspectable var maximumHeight: CGFloat = 100
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            if self.text == placeholder {
                self.textColor = placeholderColor
            }
        }
    }
    
    @IBInspectable var normalTextColor: UIColor = UIColor.darkGrayColor() {
        didSet {
            if self.text != placeholder {
                self.textColor = normalTextColor
            }
        }
    }
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            if self.text.isEmpty {
                self.text = placeholder
                self.textColor = placeholderColor
            }
        }
    }
    
    var heightConstraint: NSLayoutConstraint?
    var currentText: String! {
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
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
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
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.textDidChange()
        }
    }
    
    
    
    func didBeginEditing() {
        if self.text == placeholder {
            self.text = ""
        }
        self.textColor = normalTextColor
    }
    
    
    func didEndEditing() {
        if self.text.isEmpty {
            self.text = placeholder
            self.textColor = placeholderColor
        }
    }
    
    func textDidChange() {
        
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