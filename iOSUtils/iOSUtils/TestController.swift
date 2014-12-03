//
//  ViewController.swift
//  iOSUtils
//
//  Created by Wes Byrne on 11/21/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var colorChangeButton: CBButton!
    
    @IBOutlet weak var progressView: CBProgressView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: CBTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register for keyboard notifications to adjust it's position.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChange:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        colorChangeButton.backgroundColor = UIColor.clearColor()
        colorChangeButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        
    }


    
    @IBAction func buttonOneSelected(sender: CBButton) {
        
        if sender.selected {
            progressView.setLineWidth(3, animated: false)
            progressView.setProgress(1, animated: true)
        }
        else {
            progressView.setProgress(0, animated: false)
        }
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            if sender.selected {
                
                sender.layer.backgroundColor = UIColor.redColor().CGColor
            }
            else {
                sender.layer.backgroundColor = UIColor.whiteColor().CGColor
            }
        })
       
        
    }
    
    
    @IBAction func selectedCircleButton(sender: AnyObject) {
        progressView.setLineWidth(0, animated: true)
    }
    
    
    
    // Keyboard Handling
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        self.textView.resignFirstResponder()
    }
    
    
    
    
    func keyboardWillChange(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
                
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as NSTimeInterval
                let options = UIViewAnimationOptions(UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as NSNumber).integerValue << 16))
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: nil, action: nil)
                
                textViewBottomConstraint.constant = self.view.frame.size.height - keyboardFrame.origin.y
                UIView.animateWithDuration(duration, delay:0, options: options, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                    
                    }, completion: nil)
                
                
            }
        }
    }
    
    
    

}

