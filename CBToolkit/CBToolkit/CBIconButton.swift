//
//  CBIconButton.swift
//  WatchYourBAC
//
//  Created by Wesley Byrne on 10/22/15.
//  Copyright © 2015 Type2Designs. All rights reserved.
//

import Foundation
import UIKit


/**
 Available icons to use with CBIconButton.
 
 - None:       No icon is displayed
 - Hamburger:  A 3 bar menu hamburger
 - Close:      A close (X) icon
 - Add:        An add (+) icon
 - AngleLeft:  A left pointing cheveron (<)
 - AngleRight: A right pointing cheveron (>)
 - ArrowLeft:  A left pointing arrow
 - ArrowRight: A right pointing Arrow
 */
public enum CBIconType : NSInteger {
    case None
    case Hamburger
    case Close
    case Add
    case AngleLeft
    case AngleRight
    case ArrowLeft
    case ArrowRight
}


/// Display an icon (CBIconType), drawn and animated with core animation.
@IBDesignable public class CBIconButton : CBButton {
    
    /// The color of the icon while the button is highlighted
    @IBInspectable public var highlightTintColor: UIColor?
    /// The size of the icon within the button. The icon is always centered
    @IBInspectable public var iconSize : CGSize  = CGSize(width: 24, height: 24)
    /// The width of each of the bars used to create the icons
    @IBInspectable public var barWidth : CGFloat = 2 {
        didSet {
            bar1.lineWidth = barWidth
            bar2.lineWidth = barWidth
            bar3.lineWidth = barWidth
        }
    }
    /// If CBIconType.None is set, the button will be disabled. Otherwise it is enabled.
    @IBInspectable public var autoDisable: Bool = true

    /// The icon currently displayed in the button (read only)
    public var iconType: CBIconType { get { return _type }}
    
    private var _type : CBIconType! = .Hamburger
    private let bar1 = CAShapeLayer()
    private let bar2 = CAShapeLayer()
    private let bar3 = CAShapeLayer()
    private var iconFrame : CGRect {
        get {
            let refSize = self.bounds.size
            var rect = CGRect(x: (refSize.width/2) - iconSize.width/2, y: (refSize.width/2) - iconSize.width/2, width: iconSize.width, height: iconSize.height)
            rect = CGRectInset(rect, barWidth/2, barWidth/2)
            return rect
        }
    }
    
    override public var highlighted : Bool {
        didSet {
            if (highlightTintColor != nil) {
                let color = highlighted ? highlightTintColor!.CGColor : self.tintColor.CGColor;
                bar1.strokeColor = color
                bar2.strokeColor = color
                bar3.strokeColor = color
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        for bar in [bar1, bar2, bar3] {
            bar.lineWidth = barWidth
            bar.lineCap = kCALineCapRound
            self.layer.addSublayer(bar)
        }
        setIcon(.Hamburger, animated: false)
        self.tintColorDidChange()
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        bar1.strokeColor = self.tintColor.CGColor
        bar2.strokeColor = self.tintColor.CGColor
        bar3.strokeColor = self.tintColor.CGColor
    }
    
    
    /**
     Set the icon to be displayed in the button optionally animating the change.
     
     - parameter type:     A CBIconType to display
     - parameter animated: If the change should be animated
     */
    public func setIcon(type: CBIconType, animated: Bool) {
        self.enabled = true
        if type == .None {
            self.enabled = self.autoDisable
            setBarOpacity(0, o2: 0, o3: 0)
            let path = pathFromPosition(4, toPosition: 4)
            setBarPaths(path,
                p2: path,
                p3: path,
                animated: animated)
        }
        else if type == .Hamburger {
            setBarOpacity(1, o2: 1, o3: 1)
            setBarPaths(pathFromPosition(0, toPosition: 2),
                p2: pathFromPosition(3, toPosition: 5),
                p3: pathFromPosition(6, toPosition: 8),
                animated: animated)
        }
        else if type == .Close {
            
            setBarOpacity(1, o2: 0, o3: 1)
            setBarPaths(pathFromPosition(2, toPosition: 6),
                p2: pathFromPosition(4, toPosition: 4),
                p3: pathFromPosition(8, toPosition: 0),
                animated: animated)
        }
        else if type == .Add {
            setBarOpacity(1, o2: 0, o3: 1)
            setBarPaths(pathFromPosition(1, toPosition: 7),
                p2: pathFromPosition(4, toPosition: 4),
                p3: pathFromPosition(5, toPosition: 3),
                animated: animated)
        }
        else if type == .AngleLeft {
            setBarOpacity(1, o2: 0, o3: 1)
            setBarPaths(pathFromPosition(1, toPosition: 3),
                p2: pathFromPosition(4, toPosition: 4),
                p3: pathFromPosition(3, toPosition: 7),
                animated: animated)
        }
        else if type == .AngleRight {
            setBarOpacity(1, o2: 0, o3: 1)
            setBarPaths(pathFromPosition(5, toPosition: 7),
                p2: pathFromPosition(4, toPosition: 4),
                p3: pathFromPosition(1, toPosition: 5),
                animated: animated)
        }
        else if type == .ArrowLeft {
            setBarOpacity(1, o2: 1, o3: 1)
            self.setBarPaths(pathFromPosition(1, toPosition: 3),
                p2: pathFromPosition(3, toPosition: 5),
                p3: pathFromPosition(3, toPosition: 7),
                animated: animated)        }
        else if type == .ArrowRight {
            setBarOpacity(1, o2: 1, o3: 1)
            self.setBarPaths(pathFromPosition(5, toPosition: 7),
                p2: pathFromPosition(5, toPosition: 3),
                p3: pathFromPosition(1, toPosition: 5),
                animated: animated)
        }
        self._type = type;
    }
    
    private func setBarOpacity(o1: Float, o2: Float, o3: Float) {
        bar1.opacity = o1
        bar2.opacity = o2
        bar3.opacity = o3
    }
    
    private func setBarPaths(p1: CGPath, p2: CGPath, p3: CGPath, animated: Bool) {
        if animated {
            bar1.setPathAnimated(p1)
            bar2.setPathAnimated(p2)
            bar3.setPathAnimated(p3)
        }
        else {
            bar1.path = p1
            bar2.path = p2
            bar3.path = p3
        }
    }
    
    private func pointAtPosition(pos: Int) -> CGPoint {
        let iFrame = iconFrame
        var point = CGPoint(x: 0, y: 0)
        
        if (pos < 3) { point.y = CGRectGetMinY(iFrame) }
        else if pos < 6 { point.y = CGRectGetMidY(iFrame) }
        else { point.y = CGRectGetMaxY(iFrame)  }
        
        let vPos = pos % 3
        if      vPos == 0 { point.x = CGRectGetMinX(iFrame) }
        else if vPos == 1 { point.x = CGRectGetMidX(iFrame) }
        else { point.x = CGRectGetMaxX(iFrame)  }
        
        return point
    }
    
    private func pathFromPosition(p1: Int, toPosition p2: Int) -> CGPath {
        let path = UIBezierPath()
        var pt1 = pointAtPosition(p1)
        var pt2 = pointAtPosition(p2)
        
        let adjust = sqrt(max(iconSize.width, iconSize.height))
        
        if p1 < 3 && p2 < 3 {
            pt1.y = pt1.y + adjust
            pt2.y = pt2.y + adjust
        }
        else if p1 > 5 && p2 > 5 {
            pt1.y = pt1.y - adjust
            pt2.y = pt2.y - adjust
        }
        else if (p1 == 0 && p2 == 8) {
            pt1 = CGPoint(x: pt1.x + adjust, y: pt1.y + adjust)
            pt2 = CGPoint(x: pt2.x - adjust, y: pt2.y - adjust)
        }
        else if (p1 == 8 && p2 == 0) {
            pt1 = CGPoint(x: pt1.x - adjust, y: pt1.y - adjust)
            pt2 = CGPoint(x: pt2.x + adjust, y: pt2.y + adjust)
        }
        else if (p1 == 6 && p2 == 2) {
            pt1 = CGPoint(x: pt1.x + adjust, y: pt1.y - adjust)
            pt2 = CGPoint(x: pt2.x - adjust, y: pt2.y + adjust)
        }
        else if (p1 == 2 && p2 == 6) {
            pt1 = CGPoint(x: pt1.x - adjust, y: pt1.y + adjust)
            pt2 = CGPoint(x: pt2.x + adjust, y: pt2.y - adjust)
        }
        path.moveToPoint(pt1)
        path.addLineToPoint(pt2)
        path.lineWidth = barWidth
        path.lineCapStyle = CGLineCap.Round
        return path.CGPath
    }
}
