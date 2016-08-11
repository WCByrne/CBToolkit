//
//  CBControls.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/3/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


/// A circular progress indicator
@IBDesignable public class CBProgressView : UIControl {
    
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer: CAShapeLayer = CAShapeLayer()
    private var _lineWidth : CGFloat = 2
    /// The width of the progress line
    @IBInspectable public var lineWidth: CGFloat = 2 {
        didSet { self.setLineWidth(lineWidth, animated: false) }
    }
    
    /// The start (0) position
    @IBInspectable public var startPosition: CGFloat = 0 {
        didSet { progressLayer.strokeStart = startPosition }
    }
    
    var _progress : CGFloat = 0
    /// The current progress
    @IBInspectable public var progress: CGFloat = 0 {
        didSet { self.setProgress(progress, animated: false) }
    }
    /// The background color of the full circle
    @IBInspectable public var trackColor: UIColor! = UIColor.clear {
        didSet { backgroundLayer.strokeColor = trackColor.cgColor }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.prepareView()
    }
    
    func prepareView() {
        backgroundLayer.strokeColor = trackColor.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = lineWidth
        self.layer.addSublayer(backgroundLayer)
        
        progressLayer.strokeColor = tintColor.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = progress
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        self.layer.addSublayer(progressLayer)
        
        self.backgroundColor = UIColor.clear
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            self.updatePath()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if progressLayer.frame.size != self.frame.size {
            progressLayer.frame = self.bounds.insetBy(dx: 0, dy: 0)
            backgroundLayer.frame = self.bounds.insetBy(dx: 0, dy: 0)
            updatePath()
        }
    }
    
    private func updatePath() {
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY);
        let radius = (self.bounds.size.width / 2) - lineWidth/2
        let startAngle = CGFloat(2 * M_PI * Double(startPosition) - M_PI_2)
        let endAngle = startAngle + CGFloat(2 * M_PI)
        
        self.progressLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true).cgPath
        self.backgroundLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        self.progressLayer.strokeColor = tintColor.cgColor
    }
    
    
    /**
     Set the line width optionally animating the change
     
     - parameter width:    The new line width
     - parameter animated: If the change should be animated
     */
    public func setLineWidth(_ width: CGFloat, animated: Bool) {
        if animated {
            self.progressLayer.lineWidth = width
            self.backgroundLayer.lineWidth = width
            var animation: CABasicAnimation?
            animation = CABasicAnimation(keyPath: "lineWidth")
            animation!.fromValue = _lineWidth
            animation!.toValue = NSNumber(value: Float(width))
            animation!.duration = 0.2;
            self.backgroundLayer.add(animation!, forKey: "lineWidthAnimation")
            self.progressLayer.add(animation!, forKey: "lineWidthAnimation")
        }
        else {
            self.backgroundLayer.removeAnimation(forKey: "lineWidthAnimation")
            self.progressLayer.removeAnimation(forKey: "lineWidthAnimation")
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressLayer.lineWidth = width
            self.backgroundLayer.lineWidth = width
            self.updatePath()
            CATransaction.commit()
        }
        self._lineWidth = width
    }
    
    /**
     Update the progress of the view from 0 to 1
     
     - parameter progress: The new progress (0-1)
     - parameter animated: If the change should be animated
     */
    public func setProgress(_ progress: CGFloat, animated: Bool) {
        if (animated) {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = NSNumber(value: Float(self._progress));
            animation.toValue = NSNumber(value: Float(progress))
            let change = Float(abs(self._progress - progress))
            animation.duration = CFTimeInterval(change*2);
            self.progressLayer.strokeEnd = progress + startPosition;
            self.progressLayer.add(animation, forKey: "progressAnimation")
        } else {
            self.progressLayer.removeAnimation(forKey: "progressAnimation")
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressLayer.strokeEnd = progress;
            CATransaction.commit()
        }
        _progress = progress;
    }
}




/// A stylish replacement from UIActivityIndicator
@IBDesignable public class CBActivityIndicator : UIControl {
    
    private let progressLayer: CAShapeLayer = CAShapeLayer()
    private let backgroundLayer: CAShapeLayer = CAShapeLayer()
    /// The animation state of the indicator
    @IBInspectable public var animating: Bool = false {
        didSet {
            if animating {
                self.startAnimating();
            }
            else {
                self.stopAnimating()
            }
        }
    }
    /// Automatically hide the indicator when not animating (does not hide the track)
    @IBInspectable public var hidesWhenStopped: Bool = true
    
    /// The background color of the full indicator track
    @IBInspectable public var trackColor: UIColor! = UIColor.clear {
        didSet { backgroundLayer.strokeColor = trackColor.cgColor }
    }
    
    private var _lineWidth: CGFloat = 2
    /// The width of the indicator
    @IBInspectable public var lineWidth: CGFloat = 2 {
        didSet {
            self.setLineWidth(lineWidth, animated: false)
        }
    }
    
    /// The duration of a single rotation
    @IBInspectable public var rotateDuration: CGFloat = 1 {
        didSet {
            if self.animating {
                self.stopAnimating()
                self.startAnimating()
            }
        }
    }
    /// The size of the indicator around the full circle
    @IBInspectable public var indicatorSize: CGFloat = 0.5 {
        didSet {
            self.progressLayer.strokeEnd = indicatorSize
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        self.prepareView()
    }
    
    func prepareView() {
        self.backgroundColor = UIColor.clear
        
        backgroundLayer.strokeColor = trackColor.cgColor
        backgroundLayer.strokeStart = 0
        backgroundLayer.strokeEnd = 1
        backgroundLayer.fillColor = nil
        backgroundLayer.lineWidth = lineWidth
        self.layer.addSublayer(backgroundLayer)
        
        progressLayer.strokeColor = tintColor.cgColor
        progressLayer.strokeStart = 0
        progressLayer.strokeEnd = self.indicatorSize
        progressLayer.fillColor = nil
        progressLayer.lineWidth = lineWidth
        progressLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.layer.addSublayer(progressLayer)
        
        drawPath()
        if !animating && hidesWhenStopped {
            progressLayer.strokeEnd = 0
        }
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            self.drawPath()
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if progressLayer.frame.size != self.frame.size {
            progressLayer.frame = self.bounds
            drawPath()
        }
    }
    
    /**
     Begin the indicators animation
     */
    public func startAnimating() {
        if animating == false {
            animating = true
            return
        }
        self.progressLayer.removeAllAnimations()
        let anim = CABasicAnimation(keyPath: "transform.rotation.z")
        anim.duration = CFTimeInterval(rotateDuration)
        anim.isRemovedOnCompletion = false
        anim.fromValue = NSNumber(value: 0)
        anim.toValue = NSNumber(value: 6.28318531)
        anim.repeatCount = MAXFLOAT
        progressLayer.add(anim, forKey: "spin")
        
        if hidesWhenStopped {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressLayer.strokeStart = 0
            self.progressLayer.strokeEnd = 0
            CATransaction.commit()
            
            let anim = CABasicAnimation(keyPath: "strokeEnd")
            anim.fromValue = NSNumber(value: 0)
            anim.toValue = NSNumber(value: Float(indicatorSize))
            anim.duration = CFTimeInterval(0.5)
            anim.isRemovedOnCompletion = false
            self.progressLayer.strokeEnd = self.indicatorSize
            progressLayer.strokeEnd = self.indicatorSize
            progressLayer.add(anim, forKey: "show")
        }
    }
    
    /**
     Stop the indicators  animation
     */
    public func stopAnimating() {
        if animating == true {
            animating = false
        }
        if hidesWhenStopped {
            let anim = CABasicAnimation(keyPath: "strokeStart")
            anim.fromValue = NSNumber(value: 0)
            anim.toValue = NSNumber(value: Float(self.indicatorSize))
            anim.duration = CFTimeInterval(0.5)
            anim.isRemovedOnCompletion = false
            progressLayer.strokeStart = self.indicatorSize
            progressLayer.add(anim, forKey: "hide")
        }
        else {
            
            
            let rotation = self.progressLayer.presentation()!.value(forKey: "transform.rotation.z")
            self.progressLayer.removeAllAnimations()
            self.progressLayer.setValue(rotation, forKey: "transform.rotation.z")
        }
    }
    
    /**
     Update the line width optionally animating the change
     
     - parameter width:    The new width of the line
     - parameter animated: If the change should be animated
     */
    public func setLineWidth(_ width: CGFloat, animated: Bool) {
        if animated {
            self.progressLayer.lineWidth = width
            self.backgroundLayer.lineWidth = width
            var animation: CABasicAnimation?
            animation = CABasicAnimation(keyPath: "lineWidth")
            animation!.fromValue = _lineWidth
            animation!.toValue = NSNumber(value: Float(width))
            animation!.duration = 0.2;
            self.backgroundLayer.add(animation!, forKey: "lineWidthAnimation")
            self.progressLayer.add(animation!, forKey: "lineWidthAnimation")
        }
        else {
            self.backgroundLayer.removeAnimation(forKey: "lineWidthAnimation")
            self.progressLayer.removeAnimation(forKey: "lineWidthAnimation")
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.progressLayer.lineWidth = width
            self.backgroundLayer.lineWidth = width
            self.drawPath()
            CATransaction.commit()
        }
        self._lineWidth = width
    }
    
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        self.progressLayer.strokeColor = tintColor.cgColor
        
    }
    
    private func drawPath() {
        
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let radius = (self.bounds.size.width / 2) - lineWidth/2
        
        self.progressLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
        self.backgroundLayer.path = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true).cgPath
        
        progressLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.progressLayer.frame = self.bounds
    }
}










