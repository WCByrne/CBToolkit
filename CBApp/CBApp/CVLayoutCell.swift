//
//  CVLayoutCell.swift
//  CBApp
//
//  Created by Wes Byrne on 9/7/15.
//  Copyright (c) 2015 Type2Designs. All rights reserved.
//

import Foundation
import UIKit
import CBToolkit

protocol GalleryDelegate {
    func openImageEditor(_ image: UIImage)
}


class CVLayoutCell : UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, CBCollectionViewDelegateLayout {
    
    @IBOutlet weak var contentCollectionView: UICollectionView!
    var delegate: GalleryDelegate?
    
    var imgURLs : [String] = [
        "http://cdn.playbuzz.com/cdn/0079c830-3406-4c05-a5c1-bc43e8f01479/7dd84d70-768b-492b-88f7-a6c70f2db2e9.jpg",
        "https://pbs.twimg.com/profile_images/378800000532546226/dbe5f0727b69487016ffd67a6689e75a.jpeg",
        "http://dreamatico.com/data_images/cat/cat-8.jpg",
        "http://static2.businessinsider.com/image/4f3433986bb3f7b67a00003c/a-parasite-found-in-cats-could-be-manipulating-our-brains.jpg",
        "https://timedotcom.files.wordpress.com/2014/06/cat-hugs.jpg?quality=65&strip=color&w=1012",
        "http://i.telegraph.co.uk/multimedia/archive/03414/cats_2763799b_3414767a.jpg",
        "http://www.petsworld.in/blog/wp-content/uploads/2014/09/cute-kittens.jpg",
        "http://theyoutubebuzz.com/site/wp-content/uploads/2014/11/cat4.jpg",
    ]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let layout = CBCollectionViewLayout(collectionView: contentCollectionView)
        layout.minimumColumnSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemRenderDirection = CBCollectionViewLayoutItemRenderDirection.ShortestFirst
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        contentCollectionView.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 0, right: 0)
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    /* 
    CollectionView Cell size
        
    There are 3 ways to set the size CBCollectionViewLayout cells. They are used in the order here. So if aspectRatioForItemAtIndexPath is implemented it is used, else it checks the next one.
    
    1. aspectRatioForItemAtIndexPath
    2. heightForItemAtIndexPath
    3. layout.defaultItemHeight
    
    NOTE: width of the cell is always determined by the number of columns/spacing
    */
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, aspectRatioForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if (indexPath as NSIndexPath).row % 4 == 0 {
            return CGSize(width: 3, height: 2)
        }
        if (indexPath as NSIndexPath).row % 3 == 0 {
            return CGSize(width: 2, height: 3)
        }
        return CGSize(width: 1, height: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        
        let imgIndex = (indexPath as NSIndexPath).row % imgURLs.count
        let url = imgURLs[imgIndex]
        cell.imageView.onLoadTransition = UIViewAnimationOptions.transitionCrossDissolve
        cell.imageView.loadImage(at: url, completion: nil)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imgIndex = (indexPath as NSIndexPath).row % imgURLs.count
        let url = imgURLs[imgIndex]
        CBPhotoFetcher.sharedFetcher.fetchImage(at: url, completion: { (image, error, requestTime) -> Void in
            if image != nil {
                self.delegate?.openImageEditor(image!)
            }
        }, progressBlock: nil)
    }
}


class GalleryCell : UICollectionViewCell {
    @IBOutlet weak var imageView: CBImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
        self.layer.cornerRadius = 2
    }
    
}
