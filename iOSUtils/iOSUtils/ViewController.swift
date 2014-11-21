//
//  ViewController.swift
//  iOSUtils
//
//  Created by Wes Byrne on 11/21/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bouncyButtonView: BouncyButtonView!
    @IBOutlet weak var bouncyButtonPOP: BouncyButtonView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var onTouchUpBlock = {(button: BouncyButtonView) -> Bool in
            
            // POP the button before returning to normal
            if button.isEqual(self.bouncyButtonPOP) {
                return true
            }
            // Just return to normal state
            return false
        }
        
        bouncyButtonView.onTouchUpBlock = onTouchUpBlock
        bouncyButtonPOP.onTouchUpBlock = onTouchUpBlock
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

