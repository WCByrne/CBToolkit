//
//  ImageCropController.swift
//  Punned
//
//  Created by Wes Byrne on 9/26/14.
//  Copyright (c) 2014 WCBmedia. All rights reserved.
//

import Foundation
import UIKit

public protocol CBImageEditorDelegate {
    func imageEditor(editor: CBImageEditor!, didFinishEditingImage original: UIImage!, editedImage: UIImage!)
    func imageEditorDidCancel(editor: CBImageEditor!)
}


class FilterData {
    var key: String!
    var previewImage: UIImage!
    var name : String!
    var params: [NSObject:AnyObject]!
    var image: UIImage?
    
    init(key: String!, previewImage: UIImage!, name: String!, params: [NSObject:AnyObject]? = nil) {
        self.key = key
        self.previewImage = previewImage
        self.name = name
        self.params = params ?? [:]
    }
}


public class CBImageEditor: UIViewController, UIScrollViewDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var scrollView: UIScrollView!
    private var blurView: UIVisualEffectView!
    private var layerMask : CAShapeLayer?
    private var imageView: UIImageView!
    private var cropRect: CGRect! = CGRectZero
    
    private var originalImage: UIImage!
    private var editingImage: UIImage!
    private var filters: [FilterData]! = []
    private var imageContext: CIContext = CIContext(options: nil)
    
    public var delegate: CBImageEditorDelegate!
    public var cropRatio: CGSize! = CGSize(width: 1, height: 1)
    public var circleCrop: Bool = false {
        didSet {
            if circleCrop {
                self.setSquareCrop()
            }
            else {
                self.view.setNeedsLayout()
            }
        }
    }

    private var ratioConstraint: NSLayoutConstraint?
    
    public var horizontalRatio : CGSize! = CGSizeMake(3, 2)
    public var verticalRatio : CGSize! = CGSizeMake(2, 3)
    
    public var finalSize: CGSize?
    
    public  var headerView: UIView!
    public var titleLabel: UILabel!
    public var saveButton: CBButton!
    public var cancelButton: CBButton!
    
    public var squareButton: CBButton!
    public var horizontalButton: CBButton!
    public var verticalButton: CBButton!

    public var filterCV : UICollectionView!
    
    private var headerHeight: NSLayoutConstraint!
    private var filterHeightConstraint: NSLayoutConstraint!
    
    public init(image: UIImage!, style: UIBlurEffectStyle, delegate: CBImageEditorDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.originalImage = image
        if image.size.width > 3000 || image.size.height > 3000 {
            self.originalImage = image.resize(CGSizeMake(3000, 3000), contentMode: CBImageContentMode.AspectFit)
        }
        
        self.view.backgroundColor = style == UIBlurEffectStyle.Dark ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.9, alpha: 1)
        self.view.clipsToBounds = true
        
        scrollView = UIScrollView(frame: cropRect)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.center = self.view.center
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = true
        scrollView.clipsToBounds = false
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bouncesZoom = true
        scrollView.maximumZoomScale = 2
        scrollView.backgroundColor = UIColor.clearColor()
        self.view.addSubview(scrollView)
        
        
        let isPad = UI_USER_INTERFACE_IDIOM() == .Pad
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 10))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -10))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: isPad ? -70 : -62))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: isPad ? 70 : 62))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        let widthConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Width, multiplier: 1, constant: 0)
        widthConstraint.priority = 250
        self.view.addConstraint(widthConstraint)
        
        editingImage = originalImage
        imageView = UIImageView(frame: CGRectZero)
        imageView.image = editingImage
        imageView.contentMode = UIViewContentMode.ScaleToFill
        scrollView.addSubview(imageView)
        
        let effect =  UIBlurEffect(style: style)
        blurView = UIVisualEffectView(effect: effect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = self.view.frame
        blurView.userInteractionEnabled = false
        blurView.alpha = 0.95
        
        self.view.addSubview(blurView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: blurView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: blurView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: blurView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: blurView, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        
        // Title, Save, & Cancel
        
        headerView = UIView(frame: CGRectZero)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
        self.view.addSubview(headerView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0))
        headerHeight = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60)
        headerView.addConstraint(headerHeight)
        
        titleLabel = UILabel(frame: CGRectZero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 22)
        titleLabel.textColor = style == UIBlurEffectStyle.Dark ? UIColor.whiteColor() : UIColor.blackColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "Adjust your Photo"
        headerView.addSubview(titleLabel)
        
        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        titleLabel.setContentCompressionResistancePriority(250, forAxis: UILayoutConstraintAxis.Horizontal)
        
        cancelButton = CBButton(type: UIButtonType.System)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", forState: UIControlState.Normal)
        cancelButton.titleLabel?.font = UIFont(name: "Avenir-Book", size: 18)
        cancelButton.tintColor = UIColor(white: style == UIBlurEffectStyle.Dark ? 0.9 : 0.1, alpha: 1)
        cancelButton.addTarget(self, action: "cancel", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(cancelButton)
        
        cancelButton.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        headerView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: titleLabel, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: -8))
        headerView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 8))
        headerView.addConstraint(NSLayoutConstraint(item:  headerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: cancelButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        saveButton = CBButton(type: UIButtonType.System)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", forState: UIControlState.Normal)
        saveButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18)
        saveButton.tintColor = UIColor(white: style == UIBlurEffectStyle.Dark ? 0.9 : 0.1, alpha: 1)
        saveButton.addTarget(self, action: "finish", forControlEvents: UIControlEvents.TouchUpInside)
        headerView.addSubview(saveButton)
        
        saveButton.addConstraint(NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 44))
        headerView.addConstraint(NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: headerView, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -8))
        headerView.addConstraint(NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: titleLabel, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 8))
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: saveButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        
        
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
        cvLayout.minimumInteritemSpacing = 4
        cvLayout.minimumLineSpacing = 4
        filterCV = UICollectionView(frame: CGRectZero, collectionViewLayout: cvLayout)
        filterCV.registerClass(CropperFilterCell.self, forCellWithReuseIdentifier: "CropperFilterCell")
        filterCV.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
        filterCV.translatesAutoresizingMaskIntoConstraints = false
        print(filterCV.collectionViewLayout, terminator: "")
        filterCV.delegate = self
        filterCV.dataSource = self
        
        self.view.addSubview(filterCV)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: filterCV, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: filterCV, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: filterCV, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0))
        filterHeightConstraint = NSLayoutConstraint(item: filterCV, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 60 )
        filterCV.addConstraint(filterHeightConstraint)
        
        verticalButton = CBButton(type: UIButtonType.System)
        verticalButton.translatesAutoresizingMaskIntoConstraints = false
        verticalButton.addTarget(self, action: "setVerticalCrop", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(verticalButton)
        verticalButton.layer.borderColor = UIColor(white: style == UIBlurEffectStyle.Dark ? 1 : 0, alpha: 0.6).CGColor
        verticalButton.layer.borderWidth = 2
        
        self.view.addConstraint(NSLayoutConstraint(item: verticalButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: filterCV, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: verticalButton, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 8))
        verticalButton.addConstraint(NSLayoutConstraint(item: verticalButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 18))
        verticalButton.addConstraint(NSLayoutConstraint(item: verticalButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 26))
        
        horizontalButton = CBButton(type: UIButtonType.System)
        horizontalButton.translatesAutoresizingMaskIntoConstraints = false
        horizontalButton.addTarget(self, action: "setHorizontalCrop", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(horizontalButton)
        horizontalButton.layer.borderColor = UIColor(white: style == UIBlurEffectStyle.Dark ? 1 : 0, alpha: 0.6).CGColor
        horizontalButton.layer.borderWidth = 2
        
        self.view.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: verticalButton, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 8))
        horizontalButton.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 26))
        horizontalButton.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 18))
        self.view.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: verticalButton, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        squareButton = CBButton(type: UIButtonType.System)
        squareButton.translatesAutoresizingMaskIntoConstraints = false
        squareButton.addTarget(self, action: "setSquareCrop", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(squareButton)
        squareButton.layer.borderColor = UIColor(white: style == UIBlurEffectStyle.Dark ? 1 : 0, alpha: 0.6).CGColor
        squareButton.layer.borderWidth = 2
        
        self.view.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: horizontalButton, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 8))
        squareButton.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20))
        squareButton.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: verticalButton, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
        
        self.enableFilters(true, animated: false)
        
        if (originalImage.size.width > originalImage.size.height) {
            setHorizontalCrop()
        }
        else if (originalImage.size.width < originalImage.size.height) {
            setVerticalCrop()
        }
        else {
            setSquareCrop()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    public func enableAspectRatios(enable: Bool, animated: Bool) {
        if animated {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.squareButton.alpha = enable ? 1 : 0
                self.verticalButton.alpha = enable ? 1 : 0
                self.horizontalButton.alpha = enable ? 1 : 0
            })
        }
        else {
            self.squareButton.alpha = enable ? 1 : 0
            self.verticalButton.alpha = enable ? 1 : 0
            self.horizontalButton.alpha = enable ? 1 : 0
        }
    }
    
    
    public func enableFilters(enable: Bool, animated: Bool) {
        if enable {
            self.processFilters()
            self.filterCV.reloadData()
            self.filterHeightConstraint.constant = 60
        }
        else {
            self.editingImage = self.originalImage
            self.imageView.image = editingImage
            self.filterHeightConstraint.constant = 0
        }
        
        if animated {
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.AllowUserInteraction, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        else {
            self.view.layoutIfNeeded()
        }
    }
    
    
    private func processFilters() {
        // Filters
        let thumb = originalImage.thumbnail(200)
        filters = [
            FilterData(key: "CIVignette", previewImage: thumb, name: "Vignette", params: [kCIInputIntensityKey : NSNumber(float: 1)]),
            FilterData(key: "CIPhotoEffectChrome", previewImage: thumb, name: "Chrome"),
            FilterData(key: "CIPhotoEffectTransfer", previewImage: thumb, name: "Transfer"),
            FilterData(key: "CIPhotoEffectInstant", previewImage: thumb, name: "Instant"),
            FilterData(key: "CIPhotoEffectProcess", previewImage: thumb, name: "Process"),
            FilterData(key: "CISepiaTone", previewImage: thumb, name: "Sepia", params: [kCIInputIntensityKey : NSNumber(float: 0.8)]),
            FilterData(key: "CIPhotoEffectTonal", previewImage: thumb, name: "B&W"),
            FilterData(key: "CIPhotoEffectNoir", previewImage: thumb, name: "Noir"),
        ]
        NSOperationQueue().addOperationWithBlock({ () -> Void in
            var i = 0
            for filter in self.filters {

                let image = CIImage(CGImage: filter.previewImage!.CGImage!)
                var params = filter.params as! [String:AnyObject]
                params[kCIInputImageKey] = image
                let ciFilter = CIFilter(name: filter.key, withInputParameters: params)
                let outImage = ciFilter!.outputImage
                let cgImage = self.imageContext.createCGImage(outImage!, fromRect: outImage!.extent)
                let img = UIImage(CGImage: cgImage)
                filter.previewImage = img
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.filterCV.reloadItemsAtIndexPaths([NSIndexPath(forRow: i, inSection: 0)])
                })

                i++
            }
        })
    }

    // Hides the status bar and shrinks the custom navBar on landscape for iPhone
    override public func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        if UI_USER_INTERFACE_IDIOM() != .Pad {
            let h : CGFloat = toInterfaceOrientation != UIInterfaceOrientation.Portrait ? 44 : 64
            headerHeight.constant = h
            UIApplication.sharedApplication().setStatusBarHidden(h == 44, withAnimation: UIStatusBarAnimation.Fade)
        }
    }

    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        var shortSide = self.view.frame.size.width > self.view.frame.size.height ? self.view.frame.size.height : self.view.frame.size.width
        scrollView.setZoomScale(1.0, animated: true)
        
        cropRect = scrollView.frame
        var imageRect = cropRect
        imageRect.origin.x = 0
        imageRect.origin.y = 0
        
        // horizontal image
        let yDif = originalImage.size.height/cropRect.size.height
        let xDif = originalImage.size.width/cropRect.size.width
        
        if (yDif < xDif) {
            imageRect.size.width = originalImage.size.width * (cropRect.size.height/originalImage.size.height)
        }
            // Vertical image
        else {
            imageRect.size.height = originalImage.size.height * (cropRect.size.width/originalImage.size.width)
        }
        
        imageView.frame = imageRect
        scrollView.setZoomScale(1.0, animated: true)
        scrollView.contentSize = imageRect.size
        
        if scrollView.contentSize.height > scrollView.frame.size.height {
            scrollView.contentOffset.y = (scrollView.contentSize.height - scrollView.frame.size.height)/2
        }
        if scrollView.contentSize.width > scrollView.frame.size.width {
            scrollView.contentOffset.x = (scrollView.contentSize.width - scrollView.frame.size.width)/2
        }
        
        blurView.layer.frame = blurView.bounds
        
        let path = UIBezierPath(rect: self.view.bounds)
        let innerPath = UIBezierPath(roundedRect: cropRect, cornerRadius: circleCrop ? cropRect.size.width/2 : 0)
        path.appendPath(innerPath)
        path.usesEvenOddFillRule = true
        
        if layerMask == nil {
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.CGPath
            fillLayer.fillRule = kCAFillRuleEvenOdd
            blurView.layer.mask = fillLayer
        }
        else {
            let anim = CABasicAnimation(keyPath: "path")
            anim.duration = 1
            anim.fromValue = layerMask!.path
            anim.toValue = path.CGPath
            layerMask!.path = path.CGPath
            layerMask!.addAnimation(anim, forKey: "maskAnimation")
        }
    }
    
    func cancel() {
        self.delegate.imageEditorDidCancel(self)
    }
    
    public func finish() {
        var rect = self.view.convertRect(cropRect, toView: imageView)
        
        let scale = (originalImage.size.width/imageView.frame.size.width)
        rect.origin.x = (rect.origin.x * scale) * scrollView.zoomScale
        rect.origin.y = (rect.origin.y * scale) * scrollView.zoomScale
        rect.size.width = (rect.size.width * scale) * scrollView.zoomScale
        rect.size.height = (rect.size.height * scale) * scrollView.zoomScale
        
        var croppedImage = editingImage.crop(rect)
        if finalSize != nil {
            croppedImage = croppedImage.resize(finalSize!, contentMode: CBImageContentMode.AspectFit)
        }

        self.delegate.imageEditor(self, didFinishEditingImage: self.originalImage, editedImage: croppedImage)
    }
    
    
    public func setSquareCrop() {
        if ratioConstraint != nil {
            self.view.removeConstraint(ratioConstraint!)
        }
        ratioConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        self.view.addConstraint(ratioConstraint!)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        squareButton.backgroundColor = squareButton.borderColor
        verticalButton.backgroundColor = UIColor.clearColor()
        horizontalButton.backgroundColor = UIColor.clearColor()
        
    }
    public func setHorizontalCrop() {
        circleCrop = false
        if ratioConstraint != nil {
            self.view.removeConstraint(ratioConstraint!)
        }
        ratioConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Height, multiplier: horizontalRatio.width/horizontalRatio.height, constant: 0)
        self.view.addConstraint(ratioConstraint!)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        squareButton.backgroundColor = UIColor.clearColor()
        verticalButton.backgroundColor = UIColor.clearColor()
        horizontalButton.backgroundColor = horizontalButton.borderColor
    }
    
    public func setVerticalCrop() {
        circleCrop = false
        if ratioConstraint != nil {
            self.view.removeConstraint(ratioConstraint!)
        }
        ratioConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: scrollView, attribute: NSLayoutAttribute.Height, multiplier: verticalRatio.width/verticalRatio.height, constant: 0)
        self.view.addConstraint(ratioConstraint!)
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.AllowUserInteraction], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        squareButton.backgroundColor = UIColor.clearColor()
        verticalButton.backgroundColor = verticalButton.borderColor
        horizontalButton.backgroundColor = UIColor.clearColor()
    }
    
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count + 1
    }
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(54, 54)
    }
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CropperFilterCell", forIndexPath: indexPath) as! CropperFilterCell
        if indexPath.row == 0 {
            cell.imageView.image = originalImage
        }
        else {
            cell.imageView.image = filters[indexPath.row-1].previewImage
        }
        return cell
    }
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            editingImage = originalImage
        }
        else {
            let filter = filters[indexPath.row - 1]
            if filter.image != nil {
                editingImage = filter.image
            }
            else {
                let image = CIImage(CGImage: originalImage.CGImage!)
                var params = filter.params as! [String:AnyObject]
                params[kCIInputImageKey] = image
                let ciFilter = CIFilter(name: filter.key, withInputParameters: params)
                let outImage = ciFilter!.outputImage
                let cgImage = imageContext.createCGImage(outImage!, fromRect: outImage!.extent)
                let img = UIImage(CGImage: cgImage)
                filter.image = img
                editingImage = img
            }
        }
        imageView.image = editingImage
    }
}



class CropperFilterCell : UICollectionViewCell {
    
    var imageView: CBImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.cornerRadius = 2
        self.clipsToBounds = true
        imageView = CBImageView()
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.addSubview(imageView)
        imageView.addConstraintsToMatchParent()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}












