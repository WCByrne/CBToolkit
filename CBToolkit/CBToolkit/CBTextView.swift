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
                    heightConstraint!.priority = 1000
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
            self.placeholderTextView?.textColor = placeholderColor
        }
    }
    
    //    @IBInspectable public var normalTextColor: UIColor = UIColor.darkGrayColor() {
    //        didSet {
    //            if self.text != placeholder {
    //                self.textColor = normalTextColor
    //            }
    //        }
    //    }
    
    @IBInspectable public var placeholder: String = "" {
        didSet {
            if self.text.isEmpty {
                self.placeholderTextView?.text = placeholder
            }
        }
    }
    
    public override var textContainerInset: UIEdgeInsets {
        didSet {
            placeholderTextView?.textContainerInset = textContainerInset
        }
    }
    
    private var placeholderTextView : UITextView?
    
    public var heightConstraint: NSLayoutConstraint?
    
    /*!
    * @Deprecated
    */
    public var currentText: String! {
        get {
            return text
        }
    }
    
    override public var text: String! {
        didSet {
            self.textDidChange()
        }
    }
    
    
    
    /********************************************************************************
    / Initialization
    ********************************************************************************/
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        if placeholderTextView == nil {
            placeholderTextView = UITextView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
            self.addSubview(placeholderTextView!)
            placeholderTextView?.font = self.font
            placeholderTextView?.userInteractionEnabled = false
            placeholderTextView?.textColor = placeholderColor
            placeholderTextView?.textContainerInset = self.textContainerInset
            placeholderTextView?.text = self.placeholder
            placeholderTextView?.backgroundColor = UIColor.clearColor()
        }
    }
    
    override public func willMoveToSuperview(newSuperview: UIView?) {
        super.willMoveToSuperview(newSuperview)
        if newSuperview == nil {
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
        else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "textDidChange", name: UITextViewTextDidChangeNotification, object: self)
            self.superview?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.textDidChange()
        }
    }
    
    public func textDidChange() {
        let size = self.contentSize
        
        if placeholderTextView?.alpha != (self.text.isEmpty ? 1 : 0) {
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.placeholderTextView?.alpha = self.text.isEmpty ? 1 : 0
            })
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
        
        //        UIView.animateWithDuration(0.1) { () -> Void in
        self.layoutIfNeeded()
        self.superview?.layoutIfNeeded()
        if size.height > self.minimumHeight && size.height < self.maximumHeight {
            self.contentOffset = CGPointMake(0, 8)
        }
        //        }
    }
    
}