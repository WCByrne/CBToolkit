//  SupportSliderCell.swift
//  MobileMenuManager
//
//  Created by Wes Byrne on 2/11/15.
//  Copyright (c) 2015 Type 2 Designs. All rights reserved.
//

import Foundation
import UIKit


/// A very simple full size 'slider' CollectionViewLayout for horizontal sliding
public class CBSliderCollectionViewLayout : UICollectionViewFlowLayout {
    /// The currently displayed row in the collectionView. This must be set to handle autoscrolling.
    public var currentIndex: Int = 0
    
    /// Start and stop the collection view autoscroll.
    public var autoScroll: Bool = false {
        didSet {
            if autoScroll {
                startAutoScroll()
            }
            else {
                cancelAutoScroll()
            }
        }
    }
    /// The delay between scroll animations
    public var autoScrollDelay: NSTimeInterval = 5
    private var autoScrollTimer: NSTimer?
    
    public override init() {
        super.init()
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.scrollDirection = UICollectionViewScrollDirection.Horizontal
    }
    
    /**
     Initialize the layout with a collectionView
     
     - parameter collectionView: The collectionView to apply the layout to
     - returns: The intialized layout
     */
    public convenience init(collectionView: UICollectionView) {
        self.init()
        collectionView.collectionViewLayout = self;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /**
    Start the autoscroll timer to begin animated slides through the cells. Repeats until cancel is called.
    */
    public func startAutoScroll() {
        if autoScrollTimer != nil { return }
        if autoScroll {
            autoScrollTimer = NSTimer.scheduledTimerWithTimeInterval(autoScrollDelay, target: self, selector: "animateScroll", userInfo: nil, repeats: true)
        }
    }
    
    /**
    Cancel the autoscroll animations if they were previously started
    */
    public func cancelAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    internal func animateScroll() {
        if self.collectionView?.numberOfSections() == 0 { return }
        else if self.collectionView?.numberOfItemsInSection(0) == 0 { return }
        currentIndex++
        if currentIndex >= self.collectionView?.numberOfItemsInSection(0) {
            currentIndex = 0
        }
        self.collectionView?.scrollToItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
    }

    override public func collectionViewContentSize() -> CGSize {
        if collectionView?.numberOfSections() == 0 {
            return CGSizeZero
        }
        
        var contentWidth: CGFloat = 0
        for section in 0...collectionView!.numberOfSections()-1 {
            let numItems = collectionView!.numberOfItemsInSection(section)
            contentWidth = contentWidth + (CGFloat(numItems) * minimumLineSpacing) + (CGFloat(numItems) * collectionView!.frame.size.width)
        }
        
        return CGSizeMake(CGFloat(contentWidth), collectionView!.bounds.size.height)
    }
    
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if !CGRectEqualToRect(collectionView!.bounds, newBounds) {
            return true;
        }
        return false;
    }
    
    override public func prepareLayout() {
        super.prepareLayout()
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes : [UICollectionViewLayoutAttributes] = []
        if let numSections = collectionView?.numberOfSections() {
            if numSections > 0 {
                for section in 0...numSections-1 {
                    let numItems = collectionView!.numberOfItemsInSection(section)
                    if numItems > 0 {
                        for row in 0...numItems-1 {
                            let indexPath = NSIndexPath(forRow: row, inSection: section)
                            attributes.append(layoutAttributesForItemAtIndexPath(indexPath)!)
                        }
                    }
                }
            }
        }
        return attributes
    }
    
    public override func prepareForAnimatedBoundsChange(oldBounds: CGRect) {
        super.prepareForAnimatedBoundsChange(oldBounds)
        collectionView!.contentOffset = CGPointMake(CGFloat(currentIndex) * collectionView!.frame.size.width, 0)
    }
    override public func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        collectionView!.contentOffset = CGPointMake(CGFloat(currentIndex) * collectionView!.frame.size.width, 0)
    }
    
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attrs = super.layoutAttributesForItemAtIndexPath(indexPath)!
        
        let height: CGFloat = collectionView!.frame.size.height
        let width: CGFloat = collectionView!.frame.size.width
        
        var x: CGFloat = 0
        let y: CGFloat = 0
        
        if indexPath.section > 0 {
            for section in 0...indexPath.section-1 {
                let numItems = CGFloat(collectionView!.numberOfItemsInSection(section))
                x = x + (numItems * width) + (numItems * minimumLineSpacing) + sectionInset.right
            }
        }
        
        let row = CGFloat(indexPath.row)
        x = x + (row * width) + (row * minimumLineSpacing)
        
        attrs.size.height = height
        attrs.size.width = width
        
        attrs.frame.origin.x = x
        attrs.frame.origin.y = y
        
        return attrs
    }
    
    
    
}