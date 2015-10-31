//
//  CHTCollectionViewWaterfallLayout.swift
//  PinterestSwift
//
//  Created by Nicholas Tau on 6/30/14.
//  Copyright (c) 2014 Nicholas Tau. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint  {
    func add(point: CGPoint) -> CGPoint {
        return CGPoint(x: self.x + point.x, y: self.y + point.y)
    }
}


@objc public protocol CBCollectionViewDelegateLayout: UICollectionViewDelegate {
    
    /**
     The height for the item at the given indexPath (Priority 2)
     
     - parameter collectionView:       The collection view the item is in
     - parameter collectionViewLayout: The CollectionViewLayout
     - parameter indexPath:            The indexPath for the item
     
     - returns: The height for the item
     */
    optional func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: NSIndexPath) -> CGFloat
    
    /**
     The aspect ration for the item at the given indexPath (Priority 1). Width and height must be greater than 0.
     
     - parameter collectionView:       The collection view the item is in
     - parameter collectionViewLayout: The CollectionViewLayout
     - parameter indexPath:            The indexPath for the item
     
     - returns: The aspect ration for the item
     */
    optional func collectionView (collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        aspectRatioForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    
    optional func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForHeaderInSection section: NSInteger) -> CGFloat
    
    optional func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForFooterInSection section: NSInteger) -> CGFloat
    
    optional func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        numberOfColumnsInSection section: Int) -> Int
    
    optional func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets
    
    // Between to items in the same column
    optional func collectionView (collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat

    optional func collectionview(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumColumnSpacingForSectionAtIndex: NSInteger) -> CGFloat
    
    /*!
    Tells the delegate that a cell is about to be moved. Optionally cancelling or redirecting the move to a new indexPath. If the current indexPath is returned the cell will not be moved. If any other indexpath is returned the cell will be moved there. The datasource should be updated during this call.
    
    :param: collectionView       The collection view
    :param: collectionViewLayout The CollectionViewLayout
    :param: sourceIndexPath      The original position of the cell when dragging began
    :param: currentIndexPath     The current position of the cell
    :param: proposedIndexPath    The proposed new position of the cell
    
    :returns: The indexPath that the cell should be moved to.
    */
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        shouldMoveItemAtIndexPath originalIndexPath: NSIndexPath,
        currentIndexPath : NSIndexPath,
        toProposedIndexPath proposedIndexPath: NSIndexPath) -> NSIndexPath
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        didFinishMovingCellFrom originalIndexPath: NSIndexPath, finalIndexPath: NSIndexPath)
}

@objc public protocol CBCollectionViewDataSource: UICollectionViewDataSource {
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool
    optional func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath : NSIndexPath)
}


public enum CBCollectionViewLayoutItemRenderDirection : NSInteger {
    case ShortestFirst
    case LeftToRight
    case RightToLeft
}

public struct CBCollectionViewLayoutElementKind {
    public static let SectionHeader: String = "CBCollectionElementKindSectionHeader"
    public static let SectionFooter: String = "CBCollectionElementKindSectionFooter"
}

public class CBCollectionViewLayout : UICollectionViewLayout, UIGestureRecognizerDelegate {
    
    public var columnCount : NSInteger = 2 {
    didSet{
        invalidateLayout()
    }}
    
    public var minimumColumnSpacing : CGFloat = 8 {
    didSet{
        invalidateLayout()
    }}
    
    public var minimumInteritemSpacing : CGFloat = 8 {
    didSet{
        invalidateLayout()
    }}
    
    public var headerHeight : CGFloat = 0.0 {
    didSet{
        invalidateLayout()
    }}

    public var footerHeight : CGFloat = 0.0 {
    didSet{
        invalidateLayout()
    }}
    
    public var defaultItemHeight : CGFloat = 50 {
    didSet{
        invalidateLayout()
    }}

    public var sectionInset : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
    didSet{
        invalidateLayout()
    }}
    
    public var itemRenderDirection : CBCollectionViewLayoutItemRenderDirection = .LeftToRight {
    didSet{
        invalidateLayout()
    }}
    
    private var _itemWidth : CGFloat = 0
    public var itemWidth : CGFloat {
        get {
            return _itemWidth
        }
    }
    
    
    private var numSections : Int { get { return self.collectionView!.numberOfSections() }}
    private func columnsInSection(section : Int) -> Int {
        return self.delegate?.collectionView?(self.collectionView!, layout: self, numberOfColumnsInSection: section) ?? self.columnCount
    }
    private var longPressGesture : UILongPressGestureRecognizer?
    private var panGesture : UIPanGestureRecognizer?
    private var dragView : UIView?
    private var initialPosition : CGPoint! = CGPointZero
    private var selectedIndexPath  : NSIndexPath?
    private var targetIndexPath: NSIndexPath?
    public var dragEnabled : Bool = false {
        didSet {
            if longPressGesture == nil {
                longPressGesture = UILongPressGestureRecognizer(target: self, action: "handleLongPress:")
                longPressGesture?.delegate = self
                panGesture = UIPanGestureRecognizer(target: self, action: "handlePanGesture:")
                panGesture?.maximumNumberOfTouches = 1
                panGesture?.delegate = self
                
                if let gestures = self.collectionView!.gestureRecognizers {
                    for gesture in gestures {
                        if let g = gesture as? UILongPressGestureRecognizer {
                            g.requireGestureRecognizerToFail(longPressGesture!)
                        }
                    }
                }
                collectionView!.addGestureRecognizer(longPressGesture!)
                collectionView!.addGestureRecognizer(panGesture!)
            }
            
            self.panGesture?.enabled = dragEnabled
            self.longPressGesture?.enabled = dragEnabled
            if !dragEnabled {
                dragView?.removeFromSuperview()
                dragView = nil
                selectedIndexPath = nil
            }
        }
    }
    
    
//  private property and method above.
    private weak var delegate : CBCollectionViewDelegateLayout?{ get{ return self.collectionView!.delegate as? CBCollectionViewDelegateLayout }}
    private weak var dataSource : CBCollectionViewDataSource? { get { return self.collectionView!.dataSource as? CBCollectionViewDataSource }}
    
    private var columnHeights : [[CGFloat]]! = []
    private var sectionItemAttributes = NSMutableArray()
    private var allItemAttributes = NSMutableArray()
    private var headersAttributes = NSMutableDictionary()
    private var footersAttributes = NSMutableDictionary()
    private var unionRects = NSMutableArray()
    private let unionSize = 20
    
    override public init() {
        super.init()
    }
    convenience public init(collectionView: UICollectionView!) {
        self.init()
        collectionView.collectionViewLayout = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(panGesture) { return selectedIndexPath != nil }
        return true
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(longPressGesture) {
            return otherGestureRecognizer.isEqual(panGesture)
        }
        if gestureRecognizer.isEqual(panGesture) {
            return otherGestureRecognizer.isEqual(longPressGesture)
        }
        return false
    }
    
    
    func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .Began {
            let indexPath = self.collectionView?.indexPathForItemAtPoint(gesture.locationInView(self.collectionView!))
            if indexPath == nil { return }
            let canMove = self.dataSource?.collectionView?(self.collectionView!, layout: self, canMoveItemAtIndexPath: indexPath!) ?? true
            if canMove == false { return }
            
            self.selectedIndexPath = indexPath
            let cell = self.collectionView!.cellForItemAtIndexPath(indexPath!)!
            
            dragView = cell.snapshotViewAfterScreenUpdates(false)
            self.collectionView!.addSubview(dragView!)
            initialPosition = cell.center
            dragView!.frame = cell.frame
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.dragView!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                cell.alpha = 0.3
            })
        }
        // If long press ends and pan was never started, return the view to it's pace
        else if panGesture!.state != .Possible  && (gesture.state == .Ended || gesture.state == .Cancelled){
            finishDrag(nil)
        }
    }
    
    func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // just for
        if selectedIndexPath == nil { return }
        
        if gesture.state == .Changed || gesture.state == .Began {
            let offset = gesture.translationInView(self.collectionView!)
            let newCenter = initialPosition.add(offset)
            
            dragView?.center = newCenter
            
            let newIP = self.collectionView!.indexPathForItemAtPoint(newCenter)
            if newIP == nil { return }
            
            let currentIP = targetIndexPath ?? selectedIndexPath!
            if newIP!.isEqual(currentIP) { return }
            
            let adjustedIP = self.delegate?.collectionView?(self.collectionView!, layout: self,
                shouldMoveItemAtIndexPath: self.selectedIndexPath!,
                currentIndexPath : currentIP,
                toProposedIndexPath: newIP!) ?? newIP!
            
            if adjustedIP.isEqual(currentIP) { return }
            self.targetIndexPath = adjustedIP
            self.dataSource?.collectionView?(self.collectionView!, layout: self, moveItemAtIndexPath: currentIP, toIndexPath: adjustedIP)
        }
        else if gesture.state == .Ended {
            finishDrag(gesture.velocityInView(self.collectionView!))
        }
    }
    
    
    func finishDrag(velocity: CGPoint?) {
        if dragView == nil { return }
        let finalIndexPath = targetIndexPath ?? selectedIndexPath!
        
        let attr = self.layoutAttributesForItemAtIndexPath(finalIndexPath)
        let oldView = dragView!
        dragView = nil
        
        if !finalIndexPath.isEqual(selectedIndexPath) {
            self.delegate?.collectionView?(self.collectionView!, layout: self, didFinishMovingCellFrom: selectedIndexPath!, finalIndexPath: finalIndexPath)
        }
        
        self.selectedIndexPath = nil
        self.targetIndexPath = nil
        
//        let v = velocity ?? CGPointZero
        
        let cell = self.collectionView?.cellForItemAtIndexPath(finalIndexPath)
        UIView.animateWithDuration(0.35, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            oldView.frame = attr!.frame
            cell?.alpha = 1
            }, completion: { (fin) -> Void in
//                cell?.hidden = false
                oldView.removeFromSuperview()

        })
    }
    
    
    
    
    
    
    func itemWidthInSectionAtIndex (section : NSInteger) -> CGFloat {
        let colCount = self.delegate?.collectionView?(self.collectionView!, layout: self, numberOfColumnsInSection: section) ?? self.columnCount
        var insets : UIEdgeInsets!
        if let sectionInsets = self.delegate?.collectionView?(self.collectionView!, layout: self, insetForSectionAtIndex: section){
            insets = sectionInsets
        }else{
            insets = self.sectionInset
        }
        let width:CGFloat = self.collectionView!.bounds.size.width - insets.left - insets.right
        let spaceColumCount:CGFloat = CGFloat(colCount-1)
        return floor((width - (spaceColumCount*self.minimumColumnSpacing)) / CGFloat(colCount))
    }
    
    override public func prepareLayout(){
        super.prepareLayout()
        
        let numberOfSections = self.collectionView!.numberOfSections()
        if numberOfSections == 0 {
            return
        }
        
        self.headersAttributes.removeAllObjects()
        self.footersAttributes.removeAllObjects()
        self.unionRects.removeAllObjects()
        self.columnHeights.removeAll(keepCapacity: false)
        self.allItemAttributes.removeAllObjects()
        self.sectionItemAttributes.removeAllObjects()
        
        // Create default column heights for each section
        for sec in 0...self.numSections-1 {
            let colCount = self.columnsInSection(sec)
            columnHeights.append([CGFloat](count: colCount, repeatedValue: 0))
        }
        
        var top : CGFloat = 0.0
        var attributes = UICollectionViewLayoutAttributes()
        
        for var section = 0; section < numberOfSections; ++section{
            
            /*
            * 1. Get section-specific metrics (minimumInteritemSpacing, sectionInset)
            */
            let colCount = self.delegate?.collectionView?(self.collectionView!, layout: self, numberOfColumnsInSection: section) ?? self.columnCount
            let sectionInsets :  UIEdgeInsets =  self.delegate?.collectionView?(self.collectionView!, layout: self, insetForSectionAtIndex: section) ?? self.sectionInset
            let itemSpacing : CGFloat = self.delegate?.collectionView?(self.collectionView!, layout: self, minimumInteritemSpacingForSectionAtIndex: section) ?? self.minimumInteritemSpacing
            let colSpacing = self.delegate?.collectionview?(self.collectionView!, layout: self, minimumColumnSpacingForSectionAtIndex: section) ?? self.minimumColumnSpacing
            
            let contentWidth = self.collectionView!.bounds.size.width - sectionInsets.left - sectionInsets.right
            let spaceColumCount = CGFloat(colCount-1)
            let itemWidth = floor((contentWidth - (spaceColumCount*colSpacing)) / CGFloat(colCount))
            _itemWidth = itemWidth
            
            /*
            * 2. Section header
            */
            let heightHeader : CGFloat = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForHeaderInSection: section) ?? self.headerHeight
            if heightHeader > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CBCollectionViewLayoutElementKind.SectionHeader, withIndexPath: NSIndexPath(forRow: 0, inSection: section))
                attributes.frame = CGRectMake(0, top, self.collectionView!.bounds.size.width, heightHeader)
                self.headersAttributes.setObject(attributes, forKey: (section))
                self.allItemAttributes.addObject(attributes)
                top = CGRectGetMaxY(attributes.frame)
            }
            
            top += sectionInsets.top
            for var idx = 0; idx < colCount; idx++ {
                self.columnHeights[section][idx] = top;
            }
            
            /*
            * 3. Section items
            */
            let itemCount = self.collectionView!.numberOfItemsInSection(section)
            let itemAttributes = NSMutableArray(capacity: itemCount)

            // Item will be put into shortest column.
            for var idx = 0; idx < itemCount; idx++ {
                let indexPath = NSIndexPath(forItem: idx, inSection: section)
                
                let columnIndex = self.nextColumnIndexForItem(indexPath)
                let xOffset = sectionInsets.left + (itemWidth + colSpacing) * CGFloat(columnIndex)
                let yOffset = self.columnHeights[section][columnIndex]
                var itemHeight : CGFloat = 0
                let aSize = self.delegate?.collectionView?(self.collectionView!, layout: self, aspectRatioForItemAtIndexPath: indexPath)
                if aSize != nil && aSize!.width != 0 && aSize!.height != 0 {
                    let h = aSize!.height * (itemWidth/aSize!.width)
                    itemHeight = floor(h)
                }
                else {
                    itemHeight = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForItemAtIndexPath: indexPath) ?? self.defaultItemHeight
                }
                
                attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.alpha = indexPath.isEqual(targetIndexPath) ? 0.3 : 1
                attributes.frame = CGRectMake(xOffset, CGFloat(yOffset), itemWidth, itemHeight)
                itemAttributes.addObject(attributes)
                self.allItemAttributes.addObject(attributes)
                self.columnHeights[section][columnIndex] = CGRectGetMaxY(attributes.frame) + itemSpacing;
            }
            self.sectionItemAttributes.addObject(itemAttributes)
            
            /*
            * 4. Section footer
            */
            let columnIndex  = self.longestColumnIndexInSection(section)
            top = self.columnHeights[section][columnIndex] - itemSpacing + sectionInsets.bottom
    
            let footerHeight = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForFooterInSection: section) ?? self.footerHeight
            if footerHeight > 0 {
                attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CBCollectionViewLayoutElementKind.SectionFooter, withIndexPath: NSIndexPath(forItem: 0, inSection: section))
                attributes.frame = CGRectMake(0, top, self.collectionView!.bounds.size.width, footerHeight)
                self.footersAttributes.setObject(attributes, forKey: section)
                self.allItemAttributes.addObject(attributes)
                top = CGRectGetMaxY(attributes.frame)
            }
            
            for var idx = 0; idx < colCount; idx++ {
                self.columnHeights[section][idx] = top
            }
        }
        
        var idx = 0;
        let itemCounts = self.allItemAttributes.count
        while(idx < itemCounts){
            let rect1 = self.allItemAttributes.objectAtIndex(idx).frame as CGRect
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = self.allItemAttributes.objectAtIndex(idx).frame as CGRect
            self.unionRects.addObject(NSValue(CGRect:CGRectUnion(rect1,rect2)))
            idx++
        }
    }
    
    override public func collectionViewContentSize() -> CGSize{
        let numberOfSections = self.collectionView!.numberOfSections()
        if numberOfSections == 0{
            return CGSizeZero
        }
        var contentSize = self.collectionView!.bounds.size as CGSize
        let height = self.columnHeights.last?.first ?? 0
        contentSize.height = CGFloat(height)
        return  contentSize
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?{
        if indexPath.section >= self.sectionItemAttributes.count{
            return nil
        }
        if indexPath.item >= self.sectionItemAttributes.objectAtIndex(indexPath.section).count{
            return nil;
        }
        let list = self.sectionItemAttributes.objectAtIndex(indexPath.section) as! NSArray
        return (list.objectAtIndex(indexPath.item) as! UICollectionViewLayoutAttributes)
    }
    
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes{
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == CBCollectionViewLayoutElementKind.SectionHeader {
            attribute = self.headersAttributes.objectForKey(indexPath.section) as! UICollectionViewLayoutAttributes
        }else if elementKind == CBCollectionViewLayoutElementKind.SectionFooter {
            attribute = self.footersAttributes.objectForKey(indexPath.section) as! UICollectionViewLayoutAttributes
        }
        return attribute
    }
    
    override public func layoutAttributesForElementsInRect (rect : CGRect) -> [UICollectionViewLayoutAttributes] {
        var begin = 0, end = self.unionRects.count
        let attrs = NSMutableArray()
        
        for var i = 0; i < end; i++ {
            if CGRectIntersectsRect(rect, self.unionRects.objectAtIndex(i).CGRectValue){
                begin = i * unionSize;
                break
            }
        }
        for var i = self.unionRects.count - 1; i>=0; i-- {
            if CGRectIntersectsRect(rect, self.unionRects.objectAtIndex(i).CGRectValue){
                end = min((i+1)*unionSize,self.allItemAttributes.count)
                break
            }
        }
        for var i = begin; i < end; i++ {
            let attr = self.allItemAttributes.objectAtIndex(i) as! UICollectionViewLayoutAttributes
            if CGRectIntersectsRect(rect, attr.frame) {
                attrs.addObject(attr)
            }
        }
        return Array(attrs) as! [UICollectionViewLayoutAttributes]
    }
    
    override public func shouldInvalidateLayoutForBoundsChange (newBounds : CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds){
            return true
        }
        return false
    }



    /*!
    Find the shortest column in a particular section
    
    :param: section The section to find the shortest column for.
    :returns: The index of the shortest column in the given section
    */
    func shortestColumnIndexInSection(section: Int) -> NSInteger {
        let min =  self.columnHeights[section].minElement()!
        return self.columnHeights[section].indexOf(min)!
    }
    
    /*!
    Find the longest column in a particular section
    
    :param: section The section to find the longest column for.
    :returns: The index of the longest column in the given section
    */
    func longestColumnIndexInSection(section: Int) -> NSInteger {
        let max =  self.columnHeights[section].maxElement()!
        return self.columnHeights[section].indexOf(max)!
    }

    /*!
    Find the index of the column the for the next item at the given index path
    
    :param: The indexPath of the section to look ahead of
    :returns: The index of the next column
    */
    func nextColumnIndexForItem (indexPath : NSIndexPath) -> Int {
        let colCount = self.delegate?.collectionView?(self.collectionView!, layout: self, numberOfColumnsInSection: indexPath.section) ?? self.columnCount
        var index = 0
        switch (self.itemRenderDirection){
        case .ShortestFirst :
            index = self.shortestColumnIndexInSection(indexPath.section)
        case .LeftToRight :
            index = (indexPath.item%colCount)
        case .RightToLeft:
            index = (colCount - 1) - (indexPath.item % colCount);
        }
        return index
    }
    
}
