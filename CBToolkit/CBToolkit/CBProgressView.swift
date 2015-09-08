//
//  CBControls.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/3/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable public class CBProgressView : UIControl {
    
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer: CAShapeLayer = CAShapeLayer()
    
    @IBInspectable public var lineWidth: CGFloat = 2 {
        didSet {
            progressLayer.lineWidth = lineWidth
            self.updatePath()
        }
    }
    
    @IBInspectable public var startPosition: CGFloat = 0 {
        didSet { progressLayer.strokeStart = startPosition }
    }
    
    var _progress : CGFloat = 0
    @IBInspectable public var progress: CGFloat = 0 {
        didSet { self.setProgress(progress, animated: false) }
    }
    
    @IBInspectable public var trackColor: UIColor! = UIColor.clearColor() {
        didSet { backgroundLayer.strokeColor = trackColor.CGColor }
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.prepareView()
    }
    
    func prepareView() {
        backgroundLayer.strokeColor = trackColor.CGColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = lineWidth
        self.layer.addSublayer(backgroundLayer)
        
        progressLayer.strokeColor = tintColor.CGColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        self.layer.addSublayer(progressLayer)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            self.updatePath()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if progressLayer.frame.size != self.frame.size {
            progressLayer.frame = CGRectInset(self.bounds, 0, 0)
            backgroundLayer.frame = CGRectInset(self.bounds, 0, 0)
            updatePath()
        }
    }
    
    private func updatePath() {
        var center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        var radius = (self.bounds.size.width / 2) - lineWidth/2
        var startAngle = CGFloat(2 * M_PI * Double(startPosition) - M_PI_2)
        var endAngle = startAngle + CGFloat(2 * M_PI)
        
        self.progressLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
        self.backgroundLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).CGPath
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        self.progressLayer.strokeColor = tintColor.CGColor
    }
    
    
     public func setLineWidth(width: CGFloat, animated: Bool) {
        var animation: CABasicAnimation?
        if animated {
            animation = CABasicAnimation(keyPath: "lineWidth")
            animation!.fromValue = lineWidth
            animation!.toValue = NSNumber(float: Float(width))
            animation!.duration = 0.2;
        }
        self.backgroundLayer.lineWidth = width
        self.progressLayer.lineWidth = width
        self.lineWidth = width
        if animation != nil {
            self.backgroundLayer.addAnimation(animation, forKey: "lineWidthAnimation")
            self.progressLayer.addAnimation(animation, forKey: "lineWidthAnimation")
        }
        
    }
    
    
    
     public func setProgress(progress: CGFloat, animated: Bool) {
            if (animated) {
                var animation = CABasicAnimation(keyPath: "strokeEnd")
                animation.fromValue = NSNumber(float: Float(self._progress));
                animation.toValue = NSNumber(float: Float(progress))
                var change = Float(abs(self._progress - progress))
                animation.duration = CFTimeInterval(change*2);
                self.progressLayer.strokeEnd = progress + startPosition;
                self.progressLayer.addAnimation(animation, forKey: "progressAnimation")
            } else {
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                self.progressLayer.strokeEnd = progress;
                CATransaction.commit()
            }
        _progress = progress;
    }
}









 @IBDesignable public class CBActivityIndicator : UIControl {
    
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer: CAShapeLayer = CAShapeLayer()
    
    @IBInspectable public var animating: Bool = false
    @IBInspectable public var hidesWhenStopped: Bool = true
    
    @IBInspectable public var trackColor: UIColor! = UIColor.clearColor() {
        didSet { backgroundLayer.strokeColor = trackColor.CGColor }
    }
    
    @IBInspectable public var lineWidth: CGFloat = 2 {
        didSet {
            progressLayer.lineWidth = lineWidth
            backgroundLayer.lineWidth = lineWidth
            self.drawPath()
        }
    }
    
    @IBInspectable public var rotateDuration: CGFloat = 1 {
        didSet {
            if self.animating {
                self.stopAnimating()
                self.startAnimating()
            }
//            if progressLayer.animationForKey("spin") != nil {
//                
//                progressLayer.animationForKey("spin").duration = CFTimeInterval(rotateDuration)
//            }
        }
    }
    @IBInspectable public var indicatorSize: CGFloat = 0.5 {
        didSet { self.progressLayer.strokeEnd = indicatorSize }
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.prepareView()
    }
    
    func prepareView() {
        self.backgroundColor = UIColor.clearColor()
        
        backgroundLayer.strokeColor = trackColor.CGColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = lineWidth
        self.layer.addSublayer(backgroundLayer)
        
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
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        if newSuperview != nil {
            self.drawPath()
        }
    }
    
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if progressLayer.frame.size != self.frame.size {
            progressLayer.frame = CGRectInset(self.bounds, 0, 0)
            drawPath()
        }
    }
    
     public func startAnimating() {
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
    
    
     public func stopAnimating() {
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
    

    
    
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer.strokeColor = tintColor.CGColor
    }
    
    
    
    
    
    private func drawPath() {
        var center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        var radius = (self.bounds.size.width / 2) - lineWidth/2
        var startAngle : CGFloat = CGFloat(0) - CGFloat(M_PI_2)
        var endAngle: CGFloat = startAngle + 6.28318531 * indicatorSize
        
        self.progressLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
        self.backgroundLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).CGPath
        
        progressLayer.anchorPoint = CGPointMake(0.5, 0.5)
        self.progressLayer.frame = self.bounds
    }


    
}










