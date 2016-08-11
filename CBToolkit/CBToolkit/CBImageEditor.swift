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
    func imageEditor(_ editor: CBImageEditor!, didFinishEditingImage original: UIImage!, editedImage: UIImage!)
    func imageEditorDidCancel(_ editor: CBImageEditor!)
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

/// A simple photo editor allowing the user to crop, zoom and add filters to an image.
public class CBImageEditor: UIViewController, UIScrollViewDelegate,  UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private var scrollView: UIScrollView!
    private var blurView: UIVisualEffectView!
    private var layerMask : CAShapeLayer?
    private var imageView: UIImageView!
    private var cropRect: CGRect! = CGRect.zero
    
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
    
    public var horizontalRatio : CGSize! = CGSize(width: 3, height: 2)
    public var verticalRatio : CGSize! = CGSize(width: 2, height: 3)
    
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
            self.originalImage = image.resize(CGSize(width: 3000, height: 3000), contentMode: CBImageContentMode.AspectFit)
        }
        
        self.view.backgroundColor = style == UIBlurEffectStyle.dark ? UIColor(white: 0.2, alpha: 1) : UIColor(white: 0.9, alpha: 1)
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
        scrollView.backgroundColor = UIColor.clear
        self.view.addSubview(scrollView)
        
        
        let isPad = UI_USER_INTERFACE_IDIOM() == .pad
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 10))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: -10))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: isPad ? -70 : -62))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: scrollView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: isPad ? 70 : 62))
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        let widthConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        widthConstraint.priority = 250
        self.view.addConstraint(widthConstraint)
        
        editingImage = originalImage
        imageView = UIImageView(frame: CGRect.zero)
        imageView.image = editingImage
        imageView.contentMode = UIViewContentMode.scaleToFill
        scrollView.addSubview(imageView)
        
        let effect =  UIBlurEffect(style: style)
        blurView = UIVisualEffectView(effect: effect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.frame = self.view.frame
        blurView.isUserInteractionEnabled = false
        blurView.alpha = 0.95
        
        self.view.addSubview(blurView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: blurView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: blurView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: blurView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: blurView, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        
        
        // Title, Save, & Cancel
        
        headerView = UIView(frame: CGRect.zero)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
        self.view.addSubview(headerView)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0))
        headerHeight = NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60)
        headerView.addConstraint(headerHeight)
        
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont(name: "Avenir-Medium", size: 22)
        titleLabel.textColor = style == UIBlurEffectStyle.dark ? UIColor.white : UIColor.black
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = "Adjust your Photo"
        headerView.addSubview(titleLabel)
        
        titleLabel.addConstraint(NSLayoutConstraint(item: titleLabel, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44))
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.centerX, relatedBy: NSLayoutRelation.equal, toItem: titleLabel, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0))
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: titleLabel, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        titleLabel.setContentCompressionResistancePriority(250, for: UILayoutConstraintAxis.horizontal)
        
        cancelButton = CBButton(type: UIButtonType.system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel", for: UIControlState.normal)
        cancelButton.titleLabel?.font = UIFont(name: "Avenir-Book", size: 18)
        cancelButton.tintColor = UIColor(white: style == UIBlurEffectStyle.dark ? 0.9 : 0.1, alpha: 1)
        cancelButton.addTarget(self, action: #selector(CBImageEditor.cancel), for: UIControlEvents.touchUpInside)
        headerView.addSubview(cancelButton)
        
        cancelButton.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44))
        headerView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.lessThanOrEqual, toItem: titleLabel, attribute: NSLayoutAttribute.left, multiplier: 1, constant: -8))
        headerView.addConstraint(NSLayoutConstraint(item: cancelButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 8))
        headerView.addConstraint(NSLayoutConstraint(item:  headerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: cancelButton, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        
        saveButton = CBButton(type: UIButtonType.system)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.setTitle("Save", for: UIControlState.normal)
        saveButton.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 18)
        saveButton.tintColor = UIColor(white: style == UIBlurEffectStyle.dark ? 0.9 : 0.1, alpha: 1)
        saveButton.addTarget(self, action: #selector(CBImageEditor.finish), for: UIControlEvents.touchUpInside)
        headerView.addSubview(saveButton)
        
        saveButton.addConstraint(NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 44))
        headerView.addConstraint(NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: headerView, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -8))
        headerView.addConstraint(NSLayoutConstraint(item: saveButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.greaterThanOrEqual, toItem: titleLabel, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 8))
        headerView.addConstraint(NSLayoutConstraint(item: headerView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: saveButton, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        
        
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
        cvLayout.minimumInteritemSpacing = 4
        cvLayout.minimumLineSpacing = 4
        filterCV = UICollectionView(frame: CGRect.zero, collectionViewLayout: cvLayout)
        filterCV.register(CropperFilterCell.self, forCellWithReuseIdentifier: "CropperFilterCell")
        filterCV.backgroundColor = UIColor(white: 0.5, alpha: 0.1)
        filterCV.translatesAutoresizingMaskIntoConstraints = false
        print(filterCV.collectionViewLayout, terminator: "")
        filterCV.delegate = self
        filterCV.dataSource = self
        
        self.view.addSubview(filterCV)
        
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: filterCV, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: filterCV, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0))
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: filterCV, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0))
        filterHeightConstraint = NSLayoutConstraint(item: filterCV, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 60 )
        filterCV.addConstraint(filterHeightConstraint)
        
        verticalButton = CBButton(type: UIButtonType.system)
        verticalButton.translatesAutoresizingMaskIntoConstraints = false
        verticalButton.addTarget(self, action: #selector(CBImageEditor.setVerticalCrop), for: UIControlEvents.touchUpInside)
        self.view.addSubview(verticalButton)
        verticalButton.layer.borderColor = UIColor(white: style == UIBlurEffectStyle.dark ? 1 : 0, alpha: 0.6).cgColor
        verticalButton.layer.borderWidth = 2
        
        self.view.addConstraint(NSLayoutConstraint(item: verticalButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 8))
        self.view.addConstraint(NSLayoutConstraint(item: filterCV, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: verticalButton, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 8))
        verticalButton.addConstraint(NSLayoutConstraint(item: verticalButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 18))
        verticalButton.addConstraint(NSLayoutConstraint(item: verticalButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 26))
        
        horizontalButton = CBButton(type: UIButtonType.system)
        horizontalButton.translatesAutoresizingMaskIntoConstraints = false
        horizontalButton.addTarget(self, action: #selector(CBImageEditor.setHorizontalCrop), for: UIControlEvents.touchUpInside)
        self.view.addSubview(horizontalButton)
        horizontalButton.layer.borderColor = UIColor(white: style == UIBlurEffectStyle.dark ? 1 : 0, alpha: 0.6).cgColor
        horizontalButton.layer.borderWidth = 2
        
        self.view.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: verticalButton, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 8))
        horizontalButton.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 26))
        horizontalButton.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 18))
        self.view.addConstraint(NSLayoutConstraint(item: horizontalButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: verticalButton, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
        squareButton = CBButton(type: UIButtonType.system)
        squareButton.translatesAutoresizingMaskIntoConstraints = false
        squareButton.addTarget(self, action: #selector(CBImageEditor.setSquareCrop), for: UIControlEvents.touchUpInside)
        self.view.addSubview(squareButton)
        squareButton.layer.borderColor = UIColor(white: style == UIBlurEffectStyle.dark ? 1 : 0, alpha: 0.6).cgColor
        squareButton.layer.borderWidth = 2
        
        self.view.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: horizontalButton, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 8))
        squareButton.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20))
        squareButton.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: 20))
        self.view.addConstraint(NSLayoutConstraint(item: squareButton, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: verticalButton, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0))
        
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
    
    
    public func enableAspectRatios(_ enable: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
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
    
    
    public func enableFilters(_ enable: Bool, animated: Bool) {
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
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: UIViewAnimationOptions.allowUserInteraction, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: nil)
        }
        else {
            self.view.layoutIfNeeded()
        }
    }
    
    
    private func processFilters() {
        // Filters
        let thumb = originalImage.thumbnail(size: 200)
        filters = [
            FilterData(key: "CIVignette", previewImage: thumb, name: "Vignette", params: [kCIInputIntensityKey : NSNumber(value: 1)]),
            FilterData(key: "CIPhotoEffectChrome", previewImage: thumb, name: "Chrome"),
            FilterData(key: "CIPhotoEffectTransfer", previewImage: thumb, name: "Transfer"),
            FilterData(key: "CIPhotoEffectInstant", previewImage: thumb, name: "Instant"),
            FilterData(key: "CIPhotoEffectProcess", previewImage: thumb, name: "Process"),
            FilterData(key: "CISepiaTone", previewImage: thumb, name: "Sepia", params: [kCIInputIntensityKey : NSNumber(value: 0.8)]),
            FilterData(key: "CIPhotoEffectTonal", previewImage: thumb, name: "B&W"),
            FilterData(key: "CIPhotoEffectNoir", previewImage: thumb, name: "Noir"),
        ]
        OperationQueue().addOperation({ () -> Void in
            var i = 0
            for filter in self.filters {

                let image = CIImage(cgImage: filter.previewImage!.cgImage!)
                var params = filter.params as! [String:AnyObject]
                params[kCIInputImageKey] = image
                let ciFilter = CIFilter(name: filter.key, withInputParameters: params)
                let outImage = ciFilter!.outputImage
                let cgImage = self.imageContext.createCGImage(outImage!, from: outImage!.extent)
                let img = UIImage(cgImage: cgImage!)
                filter.previewImage = img
                
                OperationQueue.main.addOperation({ 
                    self.filterCV.reloadItems(at: [IndexPath(item: i, section: 0)])
                })
                i += 1
            }
        })
    }

    // Hides the status bar and shrinks the custom navBar on landscape for iPhone
    override public func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        if UI_USER_INTERFACE_IDIOM() != .pad {
            let h : CGFloat = toInterfaceOrientation != UIInterfaceOrientation.portrait ? 44 : 64
            headerHeight.constant = h
            UIApplication.shared.setStatusBarHidden(h == 44, with: UIStatusBarAnimation.fade)
        }
    }

    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        var shortSide = self.view.frame.size.width > self.view.frame.size.height ? self.view.frame.size.height : self.view.frame.size.width
        scrollView.setZoomScale(1.0, animated: true)
        
        cropRect = scrollView.frame
        var imageRect = cropRect
        imageRect?.origin.x = 0
        imageRect?.origin.y = 0
        
        // horizontal image
        let yDif = originalImage.size.height/cropRect.size.height
        let xDif = originalImage.size.width/cropRect.size.width
        
        if (yDif < xDif) {
            imageRect?.size.width = originalImage.size.width * (cropRect.size.height/originalImage.size.height)
        }
            // Vertical image
        else {
            imageRect?.size.height = originalImage.size.height * (cropRect.size.width/originalImage.size.width)
        }
        
        imageView.frame = imageRect!
        scrollView.setZoomScale(1.0, animated: true)
        scrollView.contentSize = (imageRect?.size)!
        
        if scrollView.contentSize.height > scrollView.frame.size.height {
            scrollView.contentOffset.y = (scrollView.contentSize.height - scrollView.frame.size.height)/2
        }
        if scrollView.contentSize.width > scrollView.frame.size.width {
            scrollView.contentOffset.x = (scrollView.contentSize.width - scrollView.frame.size.width)/2
        }
        
        blurView.layer.frame = blurView.bounds
        
        let path = UIBezierPath(rect: self.view.bounds)
        let innerPath = UIBezierPath(roundedRect: cropRect, cornerRadius: circleCrop ? cropRect.size.width/2 : 0)
        path.append(innerPath)
        path.usesEvenOddFillRule = true
        
        if layerMask == nil {
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = kCAFillRuleEvenOdd
            blurView.layer.mask = fillLayer
        }
        else {
            let anim = CABasicAnimation(keyPath: "path")
            anim.duration = 1
            anim.fromValue = layerMask!.path
            anim.toValue = path.cgPath
            layerMask!.path = path.cgPath
            layerMask!.add(anim, forKey: "maskAnimation")
        }
    }
    
    func cancel() {
        self.delegate.imageEditorDidCancel(self)
    }
    
    public func finish() {
        var rect = self.view.convert(cropRect, to: imageView)
        
        let scale = (originalImage.size.width/imageView.frame.size.width)
        rect.origin.x = (rect.origin.x * scale) * scrollView.zoomScale
        rect.origin.y = (rect.origin.y * scale) * scrollView.zoomScale
        rect.size.width = (rect.size.width * scale) * scrollView.zoomScale
        rect.size.height = (rect.size.height * scale) * scrollView.zoomScale
        
        var croppedImage = editingImage.crop(frame: rect)
        if finalSize != nil {
            croppedImage = croppedImage.resize(finalSize!, contentMode: CBImageContentMode.AspectFit)
        }

        self.delegate.imageEditor(self, didFinishEditingImage: self.originalImage, editedImage: croppedImage)
    }
    
    
    public func setSquareCrop() {
        if ratioConstraint != nil {
            self.view.removeConstraint(ratioConstraint!)
        }
        ratioConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.height, multiplier: 1, constant: 0)
        self.view.addConstraint(ratioConstraint!)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
                self.view.layoutIfNeeded()
        }, completion: nil)
        
        squareButton.backgroundColor = squareButton.borderColor
        verticalButton.backgroundColor = UIColor.clear
        horizontalButton.backgroundColor = UIColor.clear
        
    }
    public func setHorizontalCrop() {
        circleCrop = false
        if ratioConstraint != nil {
            self.view.removeConstraint(ratioConstraint!)
        }
        ratioConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.height, multiplier: horizontalRatio.width/horizontalRatio.height, constant: 0)
        self.view.addConstraint(ratioConstraint!)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        squareButton.backgroundColor = UIColor.clear
        verticalButton.backgroundColor = UIColor.clear
        horizontalButton.backgroundColor = horizontalButton.borderColor
    }
    
    public func setVerticalCrop() {
        circleCrop = false
        if ratioConstraint != nil {
            self.view.removeConstraint(ratioConstraint!)
        }
        ratioConstraint = NSLayoutConstraint(item: scrollView, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: scrollView, attribute: NSLayoutAttribute.height, multiplier: verticalRatio.width/verticalRatio.height, constant: 0)
        self.view.addConstraint(ratioConstraint!)
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.allowUserInteraction], animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        squareButton.backgroundColor = UIColor.clear
        verticalButton.backgroundColor = verticalButton.borderColor
        horizontalButton.backgroundColor = UIColor.clear
    }
    
    
    public func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count + 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 54, height: 54)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CropperFilterCell", for: indexPath as IndexPath) as! CropperFilterCell
        if indexPath.row == 0 {
            cell.imageView.image = originalImage
        }
        else {
            cell.imageView.image = filters[indexPath.row-1].previewImage
        }
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            editingImage = originalImage
        }
        else {
            let filter = filters[indexPath.row - 1]
            if filter.image != nil {
                editingImage = filter.image
            }
            else {
                let image = CIImage(cgImage: originalImage.cgImage!)
                var params = filter.params as! [String:AnyObject]
                params[kCIInputImageKey] = image
                let ciFilter = CIFilter(name: filter.key, withInputParameters: params)
                let outImage = ciFilter!.outputImage
                let cgImage = imageContext.createCGImage(outImage!, from: outImage!.extent)
                let img = UIImage(cgImage: cgImage!)
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
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        self.addSubview(imageView)
        imageView.addConstraintsToMatchParent()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

}












