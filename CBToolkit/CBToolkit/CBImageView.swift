//
//  CBImageView.swift
//  MobileMenuManager
//
//  Created by Wes Byrne on 12/10/14.
//  Copyright (c) 2014 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit


/// Style your imageViews and even load remote image with a url.
@IBDesignable public class CBImageView : UIImageView {
    
    private var imageURL: String?
    
    // The corner radius of the view. Animateable
    @IBInspectable public var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable public var circleCrop : Bool = false {
        didSet {
            self.layoutSubviews()
        }
    }
    
    /// the width of the image views layer border. Animateable
    @IBInspectable public var borderWidth: CGFloat = 0 {
        didSet { self.layer.borderWidth = borderWidth }
    }
    
    /// The color of the border. Animateable
    @IBInspectable public var borderColor: UIColor = UIColor.lightGrayColor() {
        didSet { self.layer.borderColor = borderColor.CGColor }
    }
    
    /// The transition to apply when a remote image is loaded
    public var onLoadTransition: UIViewAnimationOptions = UIViewAnimationOptions.TransitionNone
    
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
    
    /// An image to display if no image is set
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if (self.circleCrop) {
            let sSide = min(self.frame.size.width, self.frame.size.height)
            self.cornerRadius = sSide/2
        }
    }
    
    override public var image: UIImage? {
        didSet {
            self.layer.removeAllAnimations()
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
    
    - param: newImage An image to display in this image view
    */
     public func updateImage(newImage: UIImage?) {
        if image == nil || tinted == false {
            self.image = nil
        }
        else if image != nil {
            self.image = newImage!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
    }
    
    /**
     Load an image at the given URL using CBPhotoFetcher and display it.
     
     - parameter imgURL:     The url of the image
     - parameter completion: A completion handler. If set, the image will not be set in the view when loaded. It is up to you to set it.
     */
    public func loadImageAtURL(imgURL: String!, completion: CBImageFetchCallback?) {
        imageURL = imgURL
        CBPhotoFetcher.sharedFetcher.fetchImageAtURL(imgURL, completion: { (image, error, requestTime) -> Void in
            if imgURL != self.imageURL {
                return
            }
            if completion == nil {
                if self.onLoadTransition == UIViewAnimationOptions.TransitionNone {
                    self.image = image
                }
                else {
                    UIView.transitionWithView(self, duration: 0.3, options: self.onLoadTransition, animations: { () -> Void in
                        self.image = image
                    }, completion: nil)
                }
            }
            else {
                completion!(image: image, error: error, requestTime: requestTime)
            }
        })
    }
    
    
    
}