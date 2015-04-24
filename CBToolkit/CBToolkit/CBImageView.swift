//
//  CBImageView.swift
//  MobileMenuManager
//
//  Created by Wes Byrne on 12/10/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable public class CBImageView : UIImageView {
    
    private var imageURL: String?
    
    // The corner radius of the view. Animateable
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    /// the width of the image views layer border. Animateable
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    
    /// The color of the border. Animateable
    @IBInspectable public var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    /// Tint the image with the views tintColor property
    @IBInspectable public var tinted: Bool = false {
        didSet {
            if self.image != nil {
                self.image = self.image?.imageWithRenderingMode(tinted ? UIImageRenderingMode.AlwaysTemplate : UIImageRenderingMode.Automatic)
            }
        }
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }
    
    @IBInspectable public var placeholderImage: UIImage? {
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
    
    
    
    override public var image: UIImage? {
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
     public func updateImage(newImage: UIImage?) {
        if image == nil || tinted == false {
            self.image = nil
        }
        else if image != nil {
            self.image = newImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
    }
    
    
    
    public func loadImageAtURL(imgURL: String!, completion: CBImageFetchCallback?) {
        
        imageURL = imgURL
        
        CBPhotoFetcher.sharedFetcher.fetchImageAtURL(imgURL, completion: { (image, error) -> Void in
            if imgURL != self.imageURL {
                return
            }
            if completion == nil {
                self.image = image
            }
            else {
                completion!(image: image, error: error)
            }
        })
    }
    
    
    
}