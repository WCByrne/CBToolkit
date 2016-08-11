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
    
    /**
     Detect if the view controller was presented modally or is part of a UINavigationController stack
     
     - returns: True if the view controller is not part of a UINavigationController stack
     */
    func isModal() -> Bool {
        if self.navigationController == nil {
            return true
        }
        return self.navigationController!.viewControllers.count == 1
    }
    
    /**
     Detects the presentation mode of of the view controller and pops it off the navigation stack or dismisses the modal view
     
     - parameter animated: If the dismiss should be animated
     */
    func popOrDismiss(animated: Bool) {
        if self.isModal() {
            self.dismiss(animated: animated, completion: nil)
        }
        else {
            self.navigationController?.popViewController(animated: animated)
        }   
    }
    
    /**
     Add constraints to the view controllers view to match its parent view. This is helpful when using child view controllers.
     
     - returns: The top, right, bottom, and left contraints
     */
    func addConstraintsToMatchParent() -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        return self.view.addConstraintsToMatchParent()
    }
}


public extension UIView {
    
    /**
     Add NSLayoutContraints to the reciever to match it'parent optionally provided insets for each side. If the view does not have a superview, no constraints are added.
     
     - parameter insets: Insets to apply to the constraints for Top, Right, Bottom, and Left.
     - returns: The Top, Right, Bottom, and Top constraint added to the view.
     */
    func addConstraintsToMatchParent(insets: UIEdgeInsets? = nil) -> (top: NSLayoutConstraint, right: NSLayoutConstraint, bottom: NSLayoutConstraint, left: NSLayoutConstraint)? {
        if let sv = self.superview {
            let top = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal
                
                , toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: insets?.top ?? 0)
            let right = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: insets?.right ?? 0)
            let bottom = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: insets?.bottom ?? 0)
            let left = NSLayoutConstraint(item: sv, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: insets?.left ?? 0)
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
    
    /**
     Create an alert with the given properties.
     
     - parameter title:   The title of the alert
     - parameter message: The message of the alert
     - parameter button:  A cancel button title
     
     - returns: The UIAlertController initialized with the provided properties.
     */
    public class func alertWithTitle(title: String?, message: String?, cancelButtonTitle button: String!) -> UIAlertController  {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: button, style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
    /**
     A shorthand call to present a UIAlertController in a given UIViewController
     
     - parameter viewController: The UIViewController to present the UIAlertController in.
     */
    public func show(viewController: UIViewController) {
        viewController.present(self, animated: true, completion: nil)
    }
}


public extension Int {
    public var degreesToRadians : CGFloat {
        return CGFloat(self) * CGFloat(M_PI) / 180.0
    }
    
    public static func random(low: Int, high: Int) -> Int {
        return low + Int(arc4random_uniform(UInt32(high - low + 1)))
    }
}


public extension CAShapeLayer {
    public func setPathAnimated(_ path: CGPath) {
        self.path = path
        let anim = CABasicAnimation(keyPath: "path")
        anim.duration = 0.2
        anim.fromValue = self.presentation()?.value(forKeyPath: "path")
        anim.toValue = path
        anim.fillMode = kCAFillModeBoth
        anim.isAdditive = true
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.add(anim, forKey: "animatePath")
    }
}


public enum CBImageContentMode: Int {
    case AspectFill
    case AspectFit
}


public extension UIImage {
    
    public func crop(frame: CGRect) -> UIImage {
        let  imageRef = self.cgImage!.cropping(to: frame);
        return UIImage(cgImage: imageRef!)
    }
    
    public func thumbnail(size: Int) ->UIImage {
        return resize(CGSize(width: size, height: size), contentMode: CBImageContentMode.AspectFill)
    }
    
    public func resize(_ bounds: CGSize) -> UIImage {
        let drawTransposed  = (
            self.imageOrientation == .left ||
                self.imageOrientation == .leftMirrored ||
                self.imageOrientation == .right ||
                self.imageOrientation == .rightMirrored
        )
        return self.resize(bounds, transpose: drawTransposed, transform: self.orientationTransform(for: bounds))
    }
    
    public func resize(_ bounds: CGSize,  contentMode: CBImageContentMode!) -> UIImage {
        let horizontalRatio = bounds.width / self.size.width;
        let verticalRatio = bounds.height / self.size.height;
        let ratio = contentMode == .AspectFill ? max(horizontalRatio, verticalRatio) : min(horizontalRatio, verticalRatio)
        
        let newSize = CGSize(width: self.size.width * ratio, height: self.size.height * ratio);
        return self.resize(newSize)
    }
    
    public func fixOrientation() -> UIImage {
        if (self.imageOrientation == UIImageOrientation.up) { return self }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage!;
    }
    
    public func roundCorners(radius: Int) -> UIImage {
        let image = self.imageWithAlpha()
        let context = CGContext(data: nil,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: image.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: image.cgImage!.colorSpace!,
            bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!;
        
        // Create a clipping path with rounded corners
        context.beginPath();
        self.addRoundedRectToPath(rect: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), context: context, ovalWidth: CGFloat(radius), ovalHeight: CGFloat(radius))
        
        context.closePath()
        context.clip()
        context.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height), image: image.cgImage!)
        let clippedImage = context.makeImage()
        let roundedImage = UIImage(cgImage: clippedImage!)
        return roundedImage;
    }
    
    private func addRoundedRectToPath(rect:CGRect, context:CGContext, ovalWidth:CGFloat, ovalHeight:CGFloat) {
        if (ovalWidth == 0 || ovalHeight == 0) {
            context.addRect(rect);
            return;
        }
        context.saveGState();
        context.translateBy(x: rect.minX, y: rect.minY);
        context.scaleBy(x: ovalWidth, y: ovalHeight);
        let fw: CGFloat = rect.width / ovalWidth;
        let fh: CGFloat = rect.height / ovalHeight;
        context.moveTo(x: fw, y: fh/2);
        context.addArc(x1: fw, y1: fh, x2: fw/2, y2: fh, radius: 1);
        context.addArc(x1: 0, y1: fh, x2: 0, y2: fh/2, radius: 1);
        context.addArc(x1: 0, y1: 0, x2: fw/2, y2: 0, radius: 1);
        context.addArc(x1: fw, y1: 0, x2: fw, y2: fh/2, radius: 1);
        context.closePath();
        context.restoreGState();
    }
    
    private func hasAlpha() -> Bool {
        let alpha = self.cgImage!.alphaInfo;
        return (alpha == CGImageAlphaInfo.first ||
            alpha == CGImageAlphaInfo.last ||
            alpha == CGImageAlphaInfo.premultipliedFirst ||
            alpha == CGImageAlphaInfo.premultipliedLast);
    }
    
    private func imageWithAlpha() -> UIImage {
        if self.hasAlpha() {
            return self;
        }
        let imageRef = self.cgImage;
        let width = imageRef!.width;
        let height = imageRef!.height;
        let bInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let offscreenContext = CGContext(data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: imageRef!.colorSpace!,
             bitmapInfo: bInfo.rawValue)
        
        offscreenContext!.draw(in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)), image: imageRef!)
        let imageRefWithAlpha = offscreenContext!.makeImage()
        let imageWithAlpha = UIImage(cgImage:imageRefWithAlpha!)
        return imageWithAlpha;
    }
    
    
    private func resize(_ newSize: CGSize, transpose: Bool, transform: CGAffineTransform) -> UIImage {
        let newRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height).integral;
        let transposedRect = CGRect(x: 0, y: 0, width: newRect.size.height, height: newRect.size.width);
        let imageRef = self.cgImage;
        let bitmap = CGContext(data: nil,
            width: Int(newRect.size.width),
            height: Int(newRect.size.height),
            bitsPerComponent: imageRef!.bitsPerComponent,
            bytesPerRow: 0,
            space: imageRef!.colorSpace!,
            bitmapInfo: imageRef!.bitmapInfo.rawValue);
        
        bitmap!.concatenate(transform);
        bitmap!.interpolationQuality = CGInterpolationQuality.medium;
        bitmap!.draw(in: transpose ? transposedRect : newRect, image: imageRef!);
        let newImageRef = bitmap!.makeImage()!
        let newImage = UIImage(cgImage: newImageRef)
        return newImage
    }
    
    
    private func orientationTransform(for size: CGSize) -> CGAffineTransform {
        var transform = CGAffineTransform.identity
        
        switch (self.imageOrientation) {
        case UIImageOrientation.down,            // EXIF = 3
        UIImageOrientation.downMirrored:   // EXIF = 4
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat(M_PI))
            break;
            
        case UIImageOrientation.left,           // EXIF = 6
        UIImageOrientation.leftMirrored:   // EXIF = 5
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat(M_PI_2))
            break;
            
        case UIImageOrientation.right,          // EXIF = 8
        UIImageOrientation.rightMirrored:  // EXIF = 7
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat(-M_PI_2))
            break
        default :
            break
        }
        
        
        
        switch (self.imageOrientation) {
        case UIImageOrientation.upMirrored,     // EXIF = 2
        UIImageOrientation.downMirrored:   // EXIF = 4
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break;
            
        case UIImageOrientation.leftMirrored,   // EXIF = 5
        UIImageOrientation.rightMirrored:  // EXIF = 7
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break;
            
        default :
            break
        }
        return transform
    }
}












