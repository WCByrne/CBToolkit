//
//  CBControls.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/3/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable class CBProgressView : UIControl {

    
    let progressLayer: CAShapeLayer = CAShapeLayer()
    
//    @IBInspectable var progressColor: UIColor = UIColor.blueColor() {
//        didSet {
//            progressLayer.strokeColor = progressColor.CGColor
//            self.setNeedsDisplay()
//        }
//    }
    
    
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet { progressLayer.lineWidth = lineWidth }
    }
    
    @IBInspectable var startPosition: CGFloat = 0 {
        didSet { progressLayer.strokeStart = startPosition }
    }
    
    @IBInspectable var progress: CGFloat = 0.5
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressLayer.strokeColor = tintColor.CGColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        self.layer.addSublayer(progressLayer)
        
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        progressLayer.frame = CGRectInset(self.bounds, 0, 0)
        updatePath()
    }
    
    private func updatePath() {
        var center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        var radius = (self.bounds.size.width / 2) - lineWidth/2
        var startAngle = CGFloat(2 * M_PI * Double(startPosition) - M_PI_2)
        var endAngle = startAngle + CGFloat(2 * M_PI)
        
        self.progressLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        self.progressLayer.strokeColor = tintColor.CGColor
    }
    
    
    func setLineWidth(width: CGFloat, animated: Bool) {
        var animation: CABasicAnimation?
        if animated {
            animation = CABasicAnimation(keyPath: "lineWidth")
            animation!.fromValue = lineWidth
            animation!.toValue = NSNumber(float: Float(width))
            animation!.duration = 0.5;
            
        }
        self.progressLayer.lineWidth = width
        self.lineWidth = width
        if animation != nil {
            self.progressLayer.addAnimation(animation, forKey: "animation")
        }
        
    }
    
    
    
    func setProgress(progress: CGFloat, animated: Bool) {
        if (progress > 0) {
            if (animated) {
                var animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = self.progress == 0 ? 0 : nil;
                animation.toValue = NSNumber(float: Float(progress))
                animation.duration = 1;
                self.progressLayer.strokeEnd = progress + startPosition;
                self.progressLayer.addAnimation(animation, forKey: "animation")
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.progressLayer.strokeEnd = progress;
                CATransaction.commit()
            }
        } else {
            self.progressLayer.removeAllAnimations()
            self.progressLayer.strokeEnd = 0.0
        }
        
        self.progress = progress;
    }
}









class CBActivityIndicator : UIControl {
    
    let progressLayer: CAShapeLayer = CAShapeLayer()
    
    
    @IBInspectable var animating: Bool = false
    @IBInspectable var hidesWhenStopped: Bool = true
    
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet { progressLayer.lineWidth = lineWidth }
    }
    
    @IBInspectable var rotateDuration: CGFloat = 1 {
        didSet {
            if progressLayer.animationForKey("spin") != nil {
                progressLayer.animationForKey("spin").duration = CFTimeInterval(rotateDuration)
            }
        }
    }
    @IBInspectable var indicatorSize: CGFloat = 0.5 {
        didSet { self.progressLayer.strokeEnd = indicatorSize }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor.clearColor()
        
        progressLayer.strokeColor = tintColor.CGColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = 1
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        progressLayer.anchorPoint = CGPointMake(0.5, 0.5)
        self.layer.addSublayer(progressLayer)
        
        drawPath()
        
        if animating {
            startAnimating()
        }
        else if hidesWhenStopped {
            progressLayer.strokeEnd = 0
        }
    }
    
    
    func startAnimating() {
        self.progressLayer.removeAllAnimations()
        
        animating = true
        var anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.duration = CFTimeInterval(rotateDuration)
        anim.removedOnCompletion = false
        anim.fromValue = NSNumber(float: 0)
        anim.toValue = NSNumber(float: 6.28318531)
        anim.repeatCount = MAXFLOAT
        progressLayer.addAnimation(anim, forKey: "spin")
        
        if hidesWhenStopped {
            progressLayer.strokeStart = 0
            var anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = NSNumber(int: 0)
            anim.toValue = NSNumber(int: 1)
            anim.duration = CFTimeInterval(0.5)
            anim.removedOnCompletion = false
            progressLayer.strokeEnd = 1
            progressLayer.addAnimation(anim, forKey: "show")
        }
    }
    
    
    func stopAnimating() {
        animating = false
 
        if hidesWhenStopped {
            var anim = CABasicAnimation(keyPath: "strokeStart")
            anim.fromValue = NSNumber(int: 0)
            anim.toValue = NSNumber(int: 1)
            anim.duration = CFTimeInterval(0.5)
            anim.removedOnCompletion = false
            progressLayer.strokeStart = 1
            progressLayer.addAnimation(anim, forKey: "hide")
        }
        else {
            var rotation = self.progressLayer.presentationLayer().rotation
            self.progressLayer.removeAllAnimations()
            self.progressLayer.setValue(rotation, forKey: "transform.rotation.z")
        }
    }
    

    
    
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer.strokeColor = tintColor.CGColor
    }
    
    
    
    
    
    private func drawPath() {
        var center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        var radius = (self.bounds.size.width / 2) - lineWidth/2
        var startAngle : CGFloat = CGFloat(0) - CGFloat(M_PI_2)
        var endAngle: CGFloat = startAngle + 6.28318531 * indicatorSize
        
        self.progressLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
        
        progressLayer.anchorPoint = CGPointMake(0.5, 0.5)
        self.progressLayer.frame = self.bounds
    }


    
}










