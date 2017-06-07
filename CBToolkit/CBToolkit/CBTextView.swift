//
//  CBTextViews.swift
//  CBToolkit
//
//  Created by Wes Byrne on 11/30/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit

/// An expanding text view that adjusts it's height to contain the text that is entered.
@IBDesignable public class CBTextView: UITextView {
    
    /// Weather the text view should expand to fit the text staying within the limits of mimumumHeight and maximumHeight
    @IBInspectable public var autoExpand: Bool  = false {
        didSet {
            if autoExpand {
                if heightConstraint == nil {
                    _heightConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: minimumHeight)
                    heightConstraint!.priority = UILayoutPriority(rawValue: 1000)
                    self.addConstraint(heightConstraint!)
                    self.layoutIfNeeded()
                }
            }
            else if heightConstraint != nil {
                self.removeConstraint(self.heightConstraint!)
                self._heightConstraint = nil
            }
        }
    }
    /// The minimum height the text view should shrink to if the text does not expand it
    @IBInspectable public var minimumHeight: CGFloat = 35 {
        didSet { self.textDidChange() }
    }
    /// The maximum height the text view should grow to as text is entered
    @IBInspectable public var maximumHeight: CGFloat = 100
    /// The corner radius of the text view
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    /// The border radius of the text view
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    /// The color of the border around the text view
    @IBInspectable public var borderColor: UIColor = UIColor.clear {
        didSet { self.layer.borderColor = borderColor.cgColor }
    }
    /// The color of the placeholder text
    @IBInspectable public var placeholderColor: UIColor = UIColor.lightGray {
        didSet { self.placeholderTextView?.textColor = placeholderColor }
    }
    /// The placeholder text to display if no text is entered
    @IBInspectable public var placeholder: String = "" {
        didSet {
            if self.text.isEmpty { self.placeholderTextView?.text = placeholder }
        }
    }
    
    /// The inset of the the text
    public override var textContainerInset: UIEdgeInsets {
        didSet { placeholderTextView?.textContainerInset = textContainerInset }
    }
    
    /// The views internal height constraint used to adjust it's height based on the text
    public var heightConstraint: NSLayoutConstraint? { get { return _heightConstraint }}

    private var _heightConstraint: NSLayoutConstraint?
    private var placeholderTextView : UITextView?
    
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
            placeholderTextView = UITextView(frame: self.bounds)
            self.addSubview(placeholderTextView!)
            placeholderTextView?.font = self.font
            placeholderTextView?.isUserInteractionEnabled = false
            placeholderTextView?.textColor = placeholderColor
            placeholderTextView?.textContainerInset = self.textContainerInset
            placeholderTextView?.text = self.placeholder
            placeholderTextView?.backgroundColor = UIColor.clear
        }
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil {
            NotificationCenter.default.removeObserver(self)
        }
        else {
            NotificationCenter.default.addObserver(self, selector: #selector(CBTextView.textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
            self.superview?.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            self.textDidChange()
        }
    }
    
    @objc public func textDidChange() {
        let size = self.contentSize
        
        if placeholderTextView?.alpha != (self.text.isEmpty ? 1 : 0) {
            UIView.animate(withDuration: 0.1, animations: { () -> Void in
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
            self.contentOffset = CGPoint(x: 0, y: 8)
        }
        //        }
    }
    
}
