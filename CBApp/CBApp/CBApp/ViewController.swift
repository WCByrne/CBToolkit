//
//  ViewController.swift
//  CBApp
//
//  Created by Wesley Byrne on 9/3/15.
//  Copyright (c) 2015 Type2Designs. All rights reserved.
//

import UIKit
import CBToolkit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GalleryDelegate, CBImageEditorDelegate {

    @IBOutlet weak var contentCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var layout = CBSliderCollectionViewLayout(collectionView: contentCollectionView)
        contentCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func toggleAutoScroll(sender: CBButton) {
        var layout = contentCollectionView.collectionViewLayout as! CBSliderCollectionViewLayout
        layout.autoScroll = !layout.autoScroll
        sender.tintColor = layout.autoScroll ? nil : UIColor(white: 0, alpha: 0.3)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ViewCell", forIndexPath: indexPath) as! UICollectionViewCell
            return cell
        }
        else if indexPath.row == 1 {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("ButtonCell", forIndexPath: indexPath) as! UICollectionViewCell
        
        return cell
        }
        else if indexPath.row == 2 {
            var cell = collectionView.dequeueReusableCellWithReuseIdentifier("LoadersCell", forIndexPath: indexPath) as! UICollectionViewCell

            return cell
        }
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("CVLayoutCell", forIndexPath: indexPath) as! CVLayoutCell
        cell.delegate = self
        return cell
    }
    
    
    /* IMPORTANT 
    CBSliderCollectionViewLayout must be told what the current index is if you want to allow the user to manually scroll. Scrolling stops the current timer and resets it with this index.
    */
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        (collectionView.collectionViewLayout as! CBSliderCollectionViewLayout).currentIndex = indexPath.row
    }

    
    func openImageEditor(image: UIImage) {
        var editor = CBImageEditor(image: image, style: UIBlurEffectStyle.Light, delegate: self)
        self.presentViewController(editor, animated: true, completion: nil)
    }
    
    func imageEditor(editor: CBImageEditor!, didFinishEditingImage original: UIImage!, editedImage: UIImage!) {
        editor.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imageEditorDidCancel(editor: CBImageEditor!) {
        editor.dismissViewControllerAnimated(true, completion: nil)
    }
    
    

}

