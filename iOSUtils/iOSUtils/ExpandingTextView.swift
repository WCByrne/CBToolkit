//
//  ExpandingTextView.swift
//  iOSUtils
//
//  Created by Wes Byrne on 11/30/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


protocol ExpandingTextViewDelegate {
    func expendingTextViewDidChangeSize(textView: ExpandingTextView)
}



@IBDesignable class ExpandingTextView: UITextView {
    
    var sizeDelegate: ExpandingTextViewDelegate?
    
    @IBInspectable var minimumHeight: CGFloat = 35
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
    
    /********************************************************************************
    / Initialization
    ********************************************************************************/
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    override func willMoveToSuperview(newSuperview: UIView?) {
        
        if newSuperview == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        else {
            
            self.setTranslatesAutoresizingMaskIntoConstraints(false)
            if heightConstraint == nil {
                heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: minimumHeight)
                self.addConstraint(heightConstraint!)
            }
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange", name: UITextViewTextDidChangeNotification, object: self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didBeginEditing", name: UITextViewTextDidBeginEditingNotification, object: self)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "didEndEditing", name: UITextViewTextDidEndEditingNotification, object: self)
            
            if self.text.isEmpty {
                self.text = placeholder
                self.textColor = placeholderColor
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.textDidChange()
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        if size.height > maximumHeight {
            heightConstraint!.constant = maximumHeight
        }
        else if size.height < minimumHeight {
            heightConstraint!.constant = minimumHeight
        }
        else {
            heightConstraint!.constant = size.height
        }
        
        self.layoutIfNeeded()
        self.superview?.layoutIfNeeded()
        
        if self.delegate != nil {
            self.sizeDelegate?.expendingTextViewDidChangeSize(self)
        }
    }
    
    
    
    
    
    
    
    
}