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
    
    
    // The corner radius of the view. Animateable
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    /// the width of the image views layer border. Animateable
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    
    /// The color of the border. Animateable
    @IBInspectable var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    /// Tint the image with the views tintColor property
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
    
    
    /*!
    Set a new image respecting tinting if needed
    :param: newImage An image to display in this image view
    */
    func setImage(newImage: UIImage?) {
        if image == nil || tinted == false {
            self.image = nil
        }
        else if image != nil {
            self.image = newImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
        
        
    }
    
    
    
}