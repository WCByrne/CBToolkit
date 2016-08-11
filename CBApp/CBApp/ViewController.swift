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
        
        _ = CBSliderCollectionViewLayout(collectionView: contentCollectionView)
        contentCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func toggleAutoScroll(_ sender: CBButton) {
        let layout = contentCollectionView.collectionViewLayout as! CBSliderCollectionViewLayout
        layout.autoScroll = !layout.autoScroll
        sender.tintColor = layout.autoScroll ? nil : UIColor(white: 0, alpha: 0.3)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath as NSIndexPath).row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ViewCell", for: indexPath) 
            return cell
        }
        else if (indexPath as NSIndexPath).row == 1 {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ButtonCell", for: indexPath) 
        
        return cell
        }
        else if (indexPath as NSIndexPath).row == 2 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadersCell", for: indexPath) 

            return cell
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVLayoutCell", for: indexPath) as! CVLayoutCell
        cell.delegate = self
        return cell
    }
    
    
    /* IMPORTANT 
    CBSliderCollectionViewLayout must be told what the current index is if you want to allow the user to manually scroll. Scrolling stops the current timer and resets it with this index.
    */
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        (collectionView.collectionViewLayout as! CBSliderCollectionViewLayout).currentIndex = indexPath.row
    }

    
    func openImageEditor(_ image: UIImage) {
        let editor = CBImageEditor(image: image, style: UIBlurEffectStyle.light, delegate: self)
        self.present(editor, animated: true, completion: nil)
    }
    
    func imageEditor(_ editor: CBImageEditor!, didFinishEditingImage original: UIImage!, editedImage: UIImage!) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    func imageEditorDidCancel(_ editor: CBImageEditor!) {
        editor.dismiss(animated: true, completion: nil)
    }
    
    

}

