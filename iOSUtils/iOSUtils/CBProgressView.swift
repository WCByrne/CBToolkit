//
//  CBControls.swift
//  iOSUtils
//
//  Created by Wes Byrne on 12/3/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit



@IBDesignable class CBProgressView : UIControl {

    
    let progressLayer: CAShapeLayer = CAShapeLayer()
    
    @IBInspectable var progressColor: UIColor = UIColor.blueColor() {
        didSet {
            progressLayer.strokeColor = progressColor.CGColor
            self.setNeedsDisplay()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet { self.layer.cornerRadius = cornerRadius }
    }
    
    @IBInspectable var lineWidth: CGFloat = 2 {
        didSet { progressLayer.lineWidth = lineWidth }
    }
    
    @IBInspectable var startPosition: CGFloat = 0 {
        didSet { progressLayer.strokeStart = startPosition }
    }
    
    @IBInspectable var progress: CGFloat = 0.5
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        progressLayer.strokeColor = progressColor.CGColor
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