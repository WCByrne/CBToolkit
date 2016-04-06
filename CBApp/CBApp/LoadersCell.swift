//
//  LoadersCell.swift
//  CBApp
//
//  Created by Wes Byrne on 9/7/15.
//  Copyright (c) 2015 Type2Designs. All rights reserved.
//

import Foundation
import UIKit
import CBToolkit

class LoadersCell : UICollectionViewCell {
    @IBOutlet weak var activityIndicator: CBActivityIndicator!
    @IBOutlet weak var progressView: CBProgressView!
    @IBOutlet weak var uploadButtonView: CBButtonView!
    @IBOutlet weak var progressCompleteImageView: CBImageView!
    
    var progress : CGFloat! = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.progressCompleteImageView.alpha = 0
        self.progressCompleteImageView.transform = CGAffineTransformMakeScale(0, 0)
    }
    
    @IBAction func toggleActivityIndicator(sender: CBButton) {
        if activityIndicator.animating {
            activityIndicator.stopAnimating()
            sender.setTitle("Start", forState: UIControlState.Normal)
            sender.tintColor = UIColor.whiteColor()
        }
        else {
            activityIndicator.startAnimating()
            sender.setTitle("Stop", forState: UIControlState.Normal)
            sender.tintColor = UIColor.redColor()
        }
    }
    
    @IBAction func updateActivityWidth(sender: UISlider) {
        activityIndicator.lineWidth = CGFloat(sender.value)
        activityIndicator.layoutSubviews()
    }
    
    @IBAction func updateActivtySize(sender: UISlider) {
        activityIndicator.indicatorSize = CGFloat(sender.value)
    }
    
    @IBAction func updateActivtySpeed(sender: UISlider) {
        activityIndicator.rotateDuration = CGFloat(sender.value)
    }
    @IBAction func updateActivityTrackColor(sender: UISlider) {
        self.activityIndicator.trackColor = UIColor(white: 0, alpha: CGFloat(sender.value))
    }
    
    
    @IBAction func progressButtonSelected(sender: CBButtonView) {
        if progress == 0 {
            progressView.setProgress(0, animated: false)
            progressView.setLineWidth(10, animated: true)
            progressView.setProgress(0.05, animated: true)
            self.uploadButtonView.enabled = false
            self.incrementProgress()
        }
    }
    
    func finishProgress() {
        self.uploadButtonView.popAnimation()
        self.progressView.setLineWidth(0, animated: true)
        self.progress = 0
        self.uploadButtonView.enabled = true
        self.progressCompleteImageView.transform = CGAffineTransformMakeScale(0, 0)
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
            self.progressCompleteImageView.alpha = 1
            self.progressCompleteImageView.transform = CGAffineTransformMakeScale(1, 1)
        }) { (fin) -> Void in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW,
                Int64(1 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.progressCompleteImageView.alpha = 0
                })
                return
            }
        }
    }
    
    
    
    func incrementProgress() {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.progress = self.progress + 0.1
            if self.progress >= 1 { self.progress = 1 }
            self.progressView.setProgress(self.progress, animated: true)
            
            if self.progress == 1 {
                self.finishProgress()
            }
            else {
                self.incrementProgress()
            }
        }
    }
    
}