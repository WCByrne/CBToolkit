//
//  CBImageView.swift
//  MobileMenuManager
//
//  Created by Wes Byrne on 12/10/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable class CBImageView : UIImageView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    @IBInspectable var tinted: Bool = false {
        didSet {
            if self.image != nil {
                self.image = self.image?.imageWithRenderingMode(tinted ? UIImageRenderingMode.AlwaysTemplate : UIImageRenderingMode.Automatic)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    @IBInspectable var placeholderImage: UIImage? {
        didSet {
            if self.image == nil && placeholderImage != nil {
                if tinted {
                    self.image = placeholderImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                }
                else {
                    self.image = placeholderImage
                }
            }
        }
    }
    
    
    
    override var image: UIImage? {
        didSet {
            if image == nil && self.placeholderImage != nil {
                if tinted {
                    self.image = placeholderImage?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
                }
                else {
                    self.image = placeholderImage
                }
            }
        }
    }
    
    
    
}