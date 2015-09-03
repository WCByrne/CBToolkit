//
//  ViewController.swift
//  MobileMenuManager
//
//  Created by Wes Byrne on 1/12/15.
//  Copyright (c) 2015 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit


public extension UIViewController {
    
    func isModal() -> Bool {
        if self.navigationController == nil {
            return true
        }
        return self.navigationController!.viewControllers.count == 1
    }
    
    func popOrDismiss(animated: Bool) {
        if self.isModal() {
            self.dismissViewControllerAnimated(animated, completion: nil)
        }
        else {
            self.navigationController!.popViewControllerAnimated(animated)
        }   
    }
    func addConstraintsToMatchParent() -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        return self.view.addConstraintsToMatchParent()
    }
}


public extension UIView {
    func addConstraintsToMatchParent() -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        if let sv = self.superview {
            var top = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
            var right = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
            var bottom = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
            var left = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
            sv.addConstraints([top, bottom, right, left])
            self.setTranslatesAutoresizingMaskIntoConstraints(false)
            return (top, right, bottom, left)
        }
        return nil
    }
}





public extension UIAlertController {
    
    public class func alertWithTitle(title: String?, message: String?, cancelButtonTitle button: String!) -> UIAlertController  {
        var alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.Default, handler: nil))
        return alert
    }
    
    public func show(viewController: UIViewController) {
        viewController.presentViewController(self, animated: true, completion: nil)
    }
}



public enum CBImageContentMode: Int {
    case AspectFill
    case AspectFit
}


public extension UIImage {
    
    public func crop(frame: CGRect) -> UIImage {
        var  imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
        return UIImage(CGImage: imageRef, scale: 3, orientation: self.imageOrientation)!
    }
    
    public func thumbnail(size: Int) ->UIImage {
        return resize(CGSize(width: size, height: size), contentMode: CBImageContentMode.AspectFill)
    }
    
    public func resize(bounds: CGSize) -> UIImage {
        var drawTransposed  = (
            self.imageOrientation == .Left ||
                self.imageOrientation == .LeftMirrored ||
                self.imageOrientation == .Right ||
                self.imageOrientation == .RightMirrored
        )
        return self.resize(bounds, transpose: drawTransposed, transform: self.orientationTransforForSize(bounds))
    }
    
    public func resize(bounds: CGSize,  contentMode: CBImageContentMode!) -> UIImage {
        var horizontalRatio = bounds.width / self.size.width;
        var verticalRatio = bounds.height / self.size.height;
        var ratio = contentMode == .AspectFill ? max(horizontalRatio, verticalRatio) : min(horizontalRatio, verticalRatio)
        
        var newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
        return self.resize(newSize)
    }
    
    public func fixOrientation() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.Up) { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.drawInRect(CGRectMake(0,0, self.size.width, self.size.height))
        var normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    
    private func resize(newSize: CGSize, transpose: Bool, transform: CGAffineTransform) -> UIImage {
        var newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
        var transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
        var imageRef = self.CGImage;
        
        // Build a context that's the same dimensions as the new size
        var bitmap = CGBitmapContextCreate(nil,
            Int(newRect.size.width),
            Int(newRect.size.height),
            CGImageGetBitsPerComponent(imageRef),
            0,
            CGImageGetColorSpace(imageRef),
            CGImageGetBitmapInfo(imageRef));
        
        CGContextConcatCTM(bitmap, transform);
        CGContextSetInterpolationQuality(bitmap, kCGInterpolationMedium);
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
        var newImageRef = CGBitmapContextCreateImage(bitmap)!
        var newImage = UIImage(CGImage: newImageRef, scale: 3, orientation: UIImageOrientation.Up)!
        return newImage
    }
    
    
    
    private func orientationTransforForSize(newSize: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransformIdentity
        
        switch (self.imageOrientation) {
        case UIImageOrientation.Down,            // EXIF = 3
        UIImageOrientation.DownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break;
            
        case UIImageOrientation.Left,           // EXIF = 6
        UIImageOrientation.LeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break;
            
        case UIImageOrientation.Right,          // EXIF = 8
        UIImageOrientation.RightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height)
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2))
            break
        default :
            break
        }
        
        
        
        switch (self.imageOrientation) {
        case UIImageOrientation.UpMirrored,     // EXIF = 2
        UIImageOrientation.DownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break;
            
        case UIImageOrientation.LeftMirrored,   // EXIF = 5
        UIImageOrientation.RightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0)
            transform = CGAffineTransformScale(transform, -1, 1)
            break;
            
        default :
            break
        }
        return transform
    }
}












