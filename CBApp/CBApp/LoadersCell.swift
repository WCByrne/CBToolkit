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
        self.progressCompleteImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
    }
    
    @IBAction func toggleActivityIndicator(_ sender: CBButton) {
        if activityIndicator.animating {
            activityIndicator.stopAnimating()
            sender.setTitle("Start", for: UIControl.State.normal)
            sender.tintColor = UIColor.white
        }
        else {
            activityIndicator.startAnimating()
            sender.setTitle("Stop", for: UIControl.State.normal)
            sender.tintColor = UIColor.red
        }
    }
    
    @IBAction func updateActivityWidth(_ sender: UISlider) {
        activityIndicator.lineWidth = CGFloat(sender.value)
        activityIndicator.layoutSubviews()
    }
    
    @IBAction func updateActivtySize(_ sender: UISlider) {
        activityIndicator.indicatorSize = CGFloat(sender.value)
    }
    
    @IBAction func updateActivtySpeed(_ sender: UISlider) {
        activityIndicator.rotateDuration = CGFloat(sender.value)
    }
    @IBAction func updateActivityTrackColor(_ sender: UISlider) {
        self.activityIndicator.trackColor = UIColor(white: 0, alpha: CGFloat(sender.value))
    }
    
    
    @IBAction func progressButtonSelected(_ sender: CBButtonView) {
        if progress == 0 {
            progressView.setProgress(0, animated: false)
            progressView.setLineWidth(10, animated: true)
            progressView.setProgress(0.05, animated: true)
            self.uploadButtonView.isEnabled = false
            self.incrementProgress()
        }
    }
    
    func finishProgress() {
        self.uploadButtonView.popAnimation()
        self.progressView.setLineWidth(0, animated: true)
        self.progress = 0
        self.uploadButtonView.isEnabled = true
        self.progressCompleteImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.progressCompleteImageView.alpha = 1
            self.progressCompleteImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
        }) { (fin) -> Void in
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.progressCompleteImageView.alpha = 0
                })
                return
            }
        }
    }
    
    
    
    func incrementProgress() {
        let delayTime = DispatchTime.now() + Double(Int64(0.2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
