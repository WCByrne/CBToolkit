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

/**
 *  The delegate for CBCollectionViewLayout
 */
@objc public protocol CBCollectionViewDelegateLayout: UICollectionViewDelegate {
    
    /**
     The height for the item at the given indexPath (Priority 2)
     
     - parameter collectionView:       The collection view the item is in
     - parameter collectionViewLayout: The CollectionViewLayout
     - parameter indexPath:            The indexPath for the item
     
     - returns: The height for the item
     */
    @objc optional func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        heightForItemAtIndexPath indexPath: IndexPath) -> CGFloat
    
    /**
     The aspect ration for the item at the given indexPath (Priority 1). Width and height must be greater than 0.
     
     - parameter collectionView:       The collection view the item is in
     - parameter collectionViewLayout: The CollectionViewLayout
     - parameter indexPath:            The indexPath for the item
     
     - returns: The aspect ration for the item
     */
    @objc optional func collectionView (_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,
        aspectRatioForItemAtIndexPath indexPath: IndexPath) -> CGSize
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForHeaderInSection section: NSInteger) -> CGFloat
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        heightForFooterInSection section: NSInteger) -> CGFloat
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        numberOfColumnsInSection section: Int) -> Int
    
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: NSInteger) -> UIEdgeInsets
    
    // Between to items in the same column
    @objc optional func collectionView (_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAtIndex section: NSInteger) -> CGFloat

    @objc optional func collectionview(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
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
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        shouldMoveItemAtIndexPath originalIndexPath: IndexPath,
        currentIndexPath : IndexPath,
        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        didFinishMovingCellFrom originalIndexPath: IndexPath, finalIndexPath: IndexPath)
}

@objc public protocol CBCollectionViewDataSource: UICollectionViewDataSource {
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        canMoveItemAtIndexPath indexPath: IndexPath) -> Bool
    @objc optional func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        moveItemAtIndexPath sourceIndexPath: IndexPath, toIndexPath : IndexPath)
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


/// A feature packed collection view layout with pinterest like layouts, aspect ratio sizing, and drag and drop.
public class CBCollectionViewLayout : UICollectionViewLayout, UIGestureRecognizerDelegate {
    
    //MARK: - Default layout values
    
    /// The default column count
    public var columnCount : NSInteger = 2 {
    didSet{
        invalidateLayout()
    }}
    /// The spacing between each column
    public var minimumColumnSpacing : CGFloat = 8 {
    didSet{
        invalidateLayout()
    }}
    /// The vertical spacing between items in the same column
    public var minimumInteritemSpacing : CGFloat = 8 {
    didSet{
        invalidateLayout()
    }}
    /// The height of section header views
    public var headerHeight : CGFloat = 0.0 {
    didSet{
        invalidateLayout()
    }}
    /// The height of section footer views
    public var footerHeight : CGFloat = 0.0 {
    didSet{
        invalidateLayout()
    }}
    /// The default height to apply to all items
    public var defaultItemHeight : CGFloat = 50 {
    didSet{
        invalidateLayout()
    }}
    /// Default insets for all sections
    public var sectionInset : UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8) {
    didSet{
        invalidateLayout()
    }}
    
    // MARK: - Render Options
    
    /// A hint as to how to render items when deciding which column to place them in
    public var itemRenderDirection : CBCollectionViewLayoutItemRenderDirection = .LeftToRight {
    didSet{
        invalidateLayout()
    }}
    
    private var _itemWidth : CGFloat = 0
    /// the calculated width of items based on the total width and number of columns (read only)
    public var itemWidth : CGFloat {
        get {
            return _itemWidth
        }
    }
    
    
    private var numSections : Int { get { return self.collectionView!.numberOfSections }}
    private func columns(in section: Int) -> Int {
        return self.delegate?.collectionView?(self.collectionView!, layout: self, numberOfColumnsInSection: section) ?? self.columnCount
    }
    private var longPressGesture : UILongPressGestureRecognizer?
    private var panGesture : UIPanGestureRecognizer?
    private var dragView : UIView?
    private var initialPosition : CGPoint! = CGPoint.zero
    private var selectedIndexPath  : IndexPath?
    private var targetIndexPath: IndexPath?
    
    /// Enable drag and drop
    public var dragEnabled : Bool = false {
        didSet {
            if longPressGesture == nil {
                longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CBCollectionViewLayout.handleLongPress(gesture:)))
                longPressGesture?.delegate = self
                panGesture = UIPanGestureRecognizer(target: self, action: #selector(CBCollectionViewLayout.handlePanGesture(gesture:)))
                panGesture?.maximumNumberOfTouches = 1
                panGesture?.delegate = self
                
                if let gestures = self.collectionView!.gestureRecognizers {
                    for gesture in gestures {
                        if let g = gesture as? UILongPressGestureRecognizer {
                            g.require(toFail: longPressGesture!)
                        }
                    }
                }
                collectionView!.addGestureRecognizer(longPressGesture!)
                collectionView!.addGestureRecognizer(panGesture!)
            }
            
            self.panGesture?.isEnabled = dragEnabled
            self.longPressGesture?.isEnabled = dragEnabled
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
    private var sectionItemAttributes : [[UICollectionViewLayoutAttributes]] = []
    private var allItemAttributes : [UICollectionViewLayoutAttributes] = []
    private var headersAttributes : [Int:UICollectionViewLayoutAttributes] = [:]
    private var footersAttributes : [Int:UICollectionViewLayoutAttributes] = [:]
    private var unionRects = [CGRect]()
    private let unionSize = 20
    
    override public init() {
        super.init()
    }
    
    /**
     Initialize the layout with a collectionView
     
     - parameter collectionView: The collectionView to apply the layout to
     - returns: The intialized layout
     */
    convenience public init(collectionView: UICollectionView!) {
        self.init()
        collectionView.collectionViewLayout = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(panGesture) { return selectedIndexPath != nil }
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isEqual(longPressGesture) {
            return otherGestureRecognizer.isEqual(panGesture)
        }
        if gestureRecognizer.isEqual(panGesture) {
            return otherGestureRecognizer.isEqual(longPressGesture)
        }
        return false
    }
    
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let indexPath = self.collectionView?.indexPathForItem(at: gesture.location(in: self.collectionView!))
            if indexPath == nil { return }
            let canMove = self.dataSource?.collectionView?(self.collectionView!, layout: self, canMoveItemAtIndexPath: indexPath!) ?? true
            if canMove == false { return }
            
            self.selectedIndexPath = indexPath
            let cell = self.collectionView!.cellForItem(at: indexPath!)!
            
            dragView = cell.snapshotView(afterScreenUpdates: false)
            self.collectionView!.addSubview(dragView!)
            initialPosition = cell.center
            dragView!.frame = cell.frame
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.dragView!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                cell.alpha = 0.3
            })
        }
        // If long press ends and pan was never started, return the view to it's pace
        else if panGesture!.state != .possible  && (gesture.state == .ended || gesture.state == .cancelled){
            finishDrag(velocity: nil)
        }
    }
    
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        // just for
        if selectedIndexPath == nil { return }
        
        if gesture.state == .changed || gesture.state == .began {
            let offset = gesture.translation(in: self.collectionView!)
            let newCenter = initialPosition.add(point: offset)
            
            dragView?.center = newCenter
            
            let newIP = self.collectionView!.indexPathForItem(at: newCenter)
            if newIP == nil { return }
            
            let currentIP = targetIndexPath ?? selectedIndexPath!
            if newIP == currentIP { return }
            
            let adjustedIP = self.delegate?.collectionView?(self.collectionView!, layout: self,
                shouldMoveItemAtIndexPath: self.selectedIndexPath!,
                currentIndexPath : currentIP,
                toProposedIndexPath: newIP!) ?? newIP!
            
            if adjustedIP == currentIP { return }
            self.targetIndexPath = adjustedIP
            self.dataSource?.collectionView?(self.collectionView!, layout: self, moveItemAtIndexPath: currentIP, toIndexPath: adjustedIP)
        }
        else if gesture.state == .ended {
            finishDrag(velocity: gesture.velocity(in: self.collectionView!))
        }
    }
    
    
    func finishDrag(velocity: CGPoint?) {
        if dragView == nil { return }
        let finalIndexPath = targetIndexPath ?? selectedIndexPath!
        
        let attr = self.layoutAttributesForItem(at: finalIndexPath as IndexPath)
        let oldView = dragView!
        dragView = nil
        
        if finalIndexPath != selectedIndexPath {
            self.delegate?.collectionView?(self.collectionView!, layout: self, didFinishMovingCellFrom: selectedIndexPath!, finalIndexPath: finalIndexPath)
        }
        
        self.selectedIndexPath = nil
        self.targetIndexPath = nil
        
//        let v = velocity ?? CGPoint.zero
        
        let cell = self.collectionView?.cellForItem(at: finalIndexPath as IndexPath)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.95, initialSpringVelocity: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: { () -> Void in
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
    
    override public func prepare(){
        super.prepare()
        
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0 {
            return
        }
        
        self.headersAttributes.removeAll()
        self.footersAttributes.removeAll(keepingCapacity: false)
        self.unionRects.removeAll()
        self.columnHeights.removeAll(keepingCapacity: false)
        self.allItemAttributes.removeAll()
        self.sectionItemAttributes.removeAll()
        
        // Create default column heights for each section
        for sec in 0...self.numSections-1 {
            let colCount = self.columns(in: sec)
            columnHeights.append([CGFloat](repeating: 0, count: colCount))
        }
        
        var top : CGFloat = 0.0
//        var attributes = UICollectionViewLayoutAttributes()
        
        for section in 0..<numberOfSections {
            
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
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: CBCollectionViewLayoutElementKind.SectionHeader, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: self.collectionView!.bounds.size.width, height: heightHeader)
                self.headersAttributes[section] = attributes
                self.allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            top += sectionInsets.top
            for idx in 0..<colCount {
                self.columnHeights[section][idx] = top;
            }
            
            /*
            * 3. Section items
            */
            let itemCount = self.collectionView!.numberOfItems(inSection: section)
            var itemAttributes : [UICollectionViewLayoutAttributes] = []

            // Item will be put into shortest column.
            for idx in 0..<itemCount {
                let indexPath = IndexPath(item: idx, section: section)
                
                let columnIndex = self.nextColumn(forItem: indexPath)
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
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.alpha = indexPath == targetIndexPath ? 0.3 : 1
                attributes.frame = CGRect(x: xOffset, y: CGFloat(yOffset), width: itemWidth, height: itemHeight)
                itemAttributes.append(attributes)
                self.allItemAttributes.append(attributes)
                self.columnHeights[section][columnIndex] = attributes.frame.maxY + itemSpacing;
            }
            self.sectionItemAttributes.append(itemAttributes)
            
            /*
            * 4. Section footer
            */
            let columnIndex  = self.longestColumn(in: section)
            top = self.columnHeights[section][columnIndex] - itemSpacing + sectionInsets.bottom
    
            let footerHeight = self.delegate?.collectionView?(self.collectionView!, layout: self, heightForFooterInSection: section) ?? self.footerHeight
            if footerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes (forSupplementaryViewOfKind: CBCollectionViewLayoutElementKind.SectionFooter, with: IndexPath(item: 0, section: section))
                attributes.frame = CGRect(x: 0, y: top, width: self.collectionView!.bounds.size.width, height:footerHeight)
                self.footersAttributes[section] = attributes
                self.allItemAttributes.append(attributes)
                top = attributes.frame.maxY
            }
            
            for idx in 0..<colCount {
                self.columnHeights[section][idx] = top
            }
        }
        
        var idx = 0;
        let itemCounts = self.allItemAttributes.count
        while(idx < itemCounts){
            let rect1 = self.allItemAttributes[idx].frame as CGRect
            idx = min(idx + unionSize, itemCounts) - 1
            let rect2 = self.allItemAttributes[idx].frame as CGRect
            self.unionRects.append(rect1.union(rect2))
            idx += 1
        }
    }
    
    override public var collectionViewContentSize : CGSize{
        let numberOfSections = self.collectionView!.numberOfSections
        if numberOfSections == 0{
            return CGSize.zero
        }
        var contentSize = self.collectionView!.bounds.size as CGSize
        let height = self.columnHeights.last?.first ?? 0
        contentSize.height = CGFloat(height)
        return  contentSize
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if indexPath.section >= self.sectionItemAttributes.count{
            return nil
        }
        if indexPath.item >= self.sectionItemAttributes[indexPath.section].count{
            return nil;
        }
        let list = self.sectionItemAttributes[indexPath.section]
        return list[indexPath.item]
    }
    
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        var attribute = UICollectionViewLayoutAttributes()
        if elementKind == CBCollectionViewLayoutElementKind.SectionHeader {
            attribute = self.headersAttributes[indexPath.section]!
        } else if elementKind == CBCollectionViewLayoutElementKind.SectionFooter {
            attribute = self.footersAttributes[indexPath.section]!
        }
        return attribute
    }
    
    
    override public func layoutAttributesForElements (in rect : CGRect) -> [UICollectionViewLayoutAttributes] {
        
        var attrs = [UICollectionViewLayoutAttributes]()
        
        for attr in allItemAttributes {
            if attr.frame.intersects(rect) {
                attrs.append(attr)
            }
        }
        return attrs
        /*
        // This logic is flawed, the temporary fix above is not the more efficient solution
         
        var begin = 0, end = self.unionRects.count
        for i in 0..<end {
            if rect.intersects(unionRects[i]){
                begin = i * unionSize;
                break
            }
        }
        for i in stride(from: self.unionRects.count - 1, through: 0, by: -1) {
            if rect.intersects(unionRects[i]){
                end = min((i+1)*unionSize,self.allItemAttributes.count)
                break
            }
        }
        for i in begin..<end {
            let attr = self.allItemAttributes[i]
            if rect.intersects(attr.frame) {
                attrs.append(attr)
            }
        }
        return attrs
        */
    }
    
    override public func shouldInvalidateLayout (forBoundsChange newBounds : CGRect) -> Bool {
        let oldBounds = self.collectionView!.bounds
        if newBounds.width != oldBounds.width{
            return true
        }
        return false
    }



    /*!
    Find the shortest column in a particular section
    
    :param: section The section to find the shortest column for.
    :returns: The index of the shortest column in the given section
    */
    func shortestColumn(in section: Int) -> NSInteger {
        let min =  self.columnHeights[section].min()!
        return self.columnHeights[section].index(of: min)!
    }
    
    /*!
    Find the longest column in a particular section
    
    :param: section The section to find the longest column for.
    :returns: The index of the longest column in the given section
    */
    func longestColumn(in section: Int) -> NSInteger {
        let max =  self.columnHeights[section].max()!
        return self.columnHeights[section].index(of: max)!
    }

    /*!
    Find the index of the column the for the next item at the given index path
    
    :param: The indexPath of the section to look ahead of
    :returns: The index of the next column
    */
    func nextColumn(forItem atIndexPath : IndexPath) -> Int {
        let colCount = self.delegate?.collectionView?(self.collectionView!, layout: self, numberOfColumnsInSection: atIndexPath.section) ?? self.columnCount
        var index = 0
        switch (self.itemRenderDirection){
        case .ShortestFirst :
            index = self.shortestColumn(in: atIndexPath.section)
        case .LeftToRight :
            index = (atIndexPath.item%colCount)
        case .RightToLeft:
            index = (colCount - 1) - (atIndexPath.item % colCount);
        }
        return index
    }
    
}
