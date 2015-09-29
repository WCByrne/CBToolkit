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
    func addConstraintsToMatchParent(insets: UIEdgeInsets? = nil) -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        if let sv = self.superview {
            let top = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: insets?.top ?? 0)
            let right = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: insets?.right ?? 0)
            let bottom = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: insets?.bottom ?? 0)
            let left = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: insets?.left ?? 0)
            sv.addConstraints([top, bottom, right, left])
            self.translatesAutoresizingMaskIntoConstraints = false
            return (top, right, bottom, left)
        }
        else {
            print("CBToolkit Warning: Attempt to add contraints to match parent but the view had not superview.")
        }
        return nil
    }
}





public extension UIAlertController {
    
    public class func alertWithTitle(title: String?, message: String?, cancelButtonTitle button: String!) -> UIAlertController  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
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
        let  imageRef = CGImageCreateWithImageInRect(self.CGImage, frame);
        return UIImage(CGImage: imageRef!)
    }
    
    public func thumbnail(size: Int) ->UIImage {
        return resize(CGSize(width: size, height: size), contentMode: CBImageContentMode.AspectFill)
    }
    
    public func resize(bounds: CGSize) -> UIImage {
        let drawTransposed  = (
            self.imageOrientation == .Left ||
                self.imageOrientation == .LeftMirrored ||
                self.imageOrientation == .Right ||
                self.imageOrientation == .RightMirrored
        )
        return self.resize(bounds, transpose: drawTransposed, transform: self.orientationTransforForSize(bounds))
    }
    
    public func resize(bounds: CGSize,  contentMode: CBImageContentMode!) -> UIImage {
        let horizontalRatio = bounds.width / self.size.width;
        let verticalRatio = bounds.height / self.size.height;
        let ratio = contentMode == .AspectFill ? max(horizontalRatio, verticalRatio) : min(horizontalRatio, verticalRatio)
        
        let newSize = CGSizeMake(self.size.width * ratio, self.size.height * ratio);
        return self.resize(newSize)
    }
    
    public func fixOrientation() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.Up) { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.drawInRect(CGRectMake(0,0, self.size.width, self.size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    public func roundCorners(radius: Int) -> UIImage {
        let image = self.imageWithAlpha()
        let context = CGBitmapContextCreate(nil,
            Int(image.size.width),
            Int(image.size.height),
            CGImageGetBitsPerComponent(image.CGImage),
            0,
            CGImageGetColorSpace(image.CGImage),
            CGImageGetBitmapInfo(image.CGImage).rawValue)!;
        
        // Create a clipping path with rounded corners
        CGContextBeginPath(context);
        self.addRoundedRectToPath(CGRectMake(0, 0, image.size.width, image.size.height), context: context, ovalWidth: CGFloat(radius), ovalHeight: CGFloat(radius))
        
        CGContextClosePath(context)
        CGContextClip(context)
        CGContextDrawImage(context, CGRectMake(0, 0, image.size.width, image.size.height), image.CGImage)
        let clippedImage = CGBitmapContextCreateImage(context)
        let roundedImage = UIImage(CGImage: clippedImage!)
        return roundedImage;
    }
    
    private func addRoundedRectToPath(rect:CGRect, context:CGContextRef, ovalWidth:CGFloat, ovalHeight:CGFloat) {
        if (ovalWidth == 0 || ovalHeight == 0) {
            CGContextAddRect(context, rect);
            return;
        }
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
        CGContextScaleCTM(context, ovalWidth, ovalHeight);
        let fw: CGFloat = CGRectGetWidth(rect) / ovalWidth;
        let fh: CGFloat = CGRectGetHeight(rect) / ovalHeight;
        CGContextMoveToPoint(context, fw, fh/2);
        CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);
        CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1);
        CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1);
        CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1);
        CGContextClosePath(context);
        CGContextRestoreGState(context);
    }
    
    private func hasAlpha() -> Bool {
        let alpha = CGImageGetAlphaInfo(self.CGImage);
        return (alpha == CGImageAlphaInfo.First ||
            alpha == CGImageAlphaInfo.Last ||
            alpha == CGImageAlphaInfo.PremultipliedFirst ||
            alpha == CGImageAlphaInfo.PremultipliedLast);
    }
    
    private func imageWithAlpha() -> UIImage {
        if self.hasAlpha() {
            return self;
        }
        let imageRef = self.CGImage;
        let width = CGImageGetWidth(imageRef);
        let height = CGImageGetHeight(imageRef);
        let bInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)
        let offscreenContext = CGBitmapContextCreate(nil,
            width,
            height,
            8,
            0,
            CGImageGetColorSpace(imageRef),
             CGBitmapInfo.ByteOrderDefault.union(bInfo).rawValue);
        
        CGContextDrawImage(offscreenContext, CGRectMake(0, 0, CGFloat(width), CGFloat(height)), imageRef)
        let imageRefWithAlpha = CGBitmapContextCreateImage(offscreenContext)
        let imageWithAlpha = UIImage(CGImage:imageRefWithAlpha!)
        return imageWithAlpha;
    }
    
    
    private func resize(newSize: CGSize, transpose: Bool, transform: CGAffineTransform) -> UIImage {
        let newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
        let transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
        let imageRef = self.CGImage;
        let bitmap = CGBitmapContextCreate(nil,
            Int(newRect.size.width),
            Int(newRect.size.height),
            CGImageGetBitsPerComponent(imageRef),
            0,
            CGImageGetColorSpace(imageRef),
            CGImageGetBitmapInfo(imageRef).rawValue);
        
        CGContextConcatCTM(bitmap, transform);
        CGContextSetInterpolationQuality(bitmap, CGInterpolationQuality.Medium);
        CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
        let newImageRef = CGBitmapContextCreateImage(bitmap)!
        let newImage = UIImage(CGImage: newImageRef)
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












