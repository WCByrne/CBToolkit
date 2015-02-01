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
    
    
}