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
    public var autoScrollDelay: TimeInterval = 5
    private var autoScrollTimer: Timer?
    
    public override init() {
        super.init()
        self.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        self.scrollDirection = UICollectionViewScrollDirection.horizontal
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
            autoScrollTimer = Timer.scheduledTimer(timeInterval: autoScrollDelay, target: self, selector: #selector(CBSliderCollectionViewLayout.animateScroll), userInfo: nil, repeats: true)
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
        if self.collectionView?.numberOfSections == 0 { return }
        else if self.collectionView?.numberOfItems(inSection: 0) == 0 { return }
        currentIndex += 1
        if currentIndex >= self.collectionView?.numberOfItems(inSection: 0) {
            currentIndex = 0
        }
        
        
        self.collectionView?.scrollToItem(at: IndexPath(item: currentIndex, section: 0), at: UICollectionViewScrollPosition.left, animated: true)
    }
 
    
    override public var collectionViewContentSize : CGSize {
        if collectionView?.numberOfSections == 0 {
            return CGSize.zero
        }
        var contentWidth: CGFloat = 0
        for section in 0...collectionView!.numberOfSections-1 {
            let numItems = collectionView!.numberOfItems(inSection: section)
            contentWidth = contentWidth + (CGFloat(numItems) * minimumLineSpacing) + (CGFloat(numItems) * collectionView!.frame.size.width)
        }
        
        return CGSize(width: CGFloat(contentWidth), height: collectionView!.bounds.size.height)
    }
    
    
    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if !collectionView!.bounds.size.equalTo(newBounds.size) {
            return true;
        }
        return false;
    }
    
    
    var attributes : [UICollectionViewLayoutAttributes] = []
    var contentSize : CGSize = CGSize.zero
    
    override public func prepare() {
        super.prepare()
        
        let slideCount = self.collectionView?.dataSource?.collectionView(self.collectionView!, numberOfItemsInSection: 0) ?? 0
        attributes.removeAll(keepingCapacity: false)
        var x: CGFloat = 0
        
        for idx in 0..<slideCount {
            let height: CGFloat = collectionView!.frame.size.height
            let width: CGFloat = collectionView!.frame.size.width
            
            let y: CGFloat = 0
            
            let attrs = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: idx, section: 0))
            
            attrs.frame = CGRect(x: x, y: y, width: width, height: height)
            x += width
            attributes.append(attrs)
        }
        self.contentSize = CGSize(width: x, height: self.collectionView!.bounds.height)
    }
    
    override public func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes : [UICollectionViewLayoutAttributes] = []
        if let numSections = collectionView?.numberOfSections {
            if numSections > 0 {
                for section in 0...numSections-1 {
                    let numItems = collectionView!.numberOfItems(inSection: section)
                    if numItems > 0 {
                        for row in 0...numItems-1 {
                            let indexPath = IndexPath(item: row, section: section)
                            attributes.append(layoutAttributesForItem(at: indexPath)!)
                        }
                    }
                }
            }
        }
        return attributes
    }
    
    public override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        collectionView!.contentOffset = CGPoint(x: CGFloat(currentIndex) * collectionView!.frame.size.width, y: 0)
    }
    override public func finalizeAnimatedBoundsChange() {
        super.finalizeAnimatedBoundsChange()
        collectionView!.contentOffset = CGPoint(x: CGFloat(currentIndex) * collectionView!.frame.size.width, y: 0)
    }
    
    override public func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attributes[indexPath.item]
    }
    
    
    
}
