//
//  CBPhotoFetcher.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/6/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


public typealias CBImageFetchCallback = (image: UIImage?, error: NSError?, fromCache: Bool)->Void
public typealias CBProgressBlock = (progress: Float)->Void
public typealias CBNetworkActivityCountChangedBlock = (change: Int, total: Int)->Void

/// An image fetching util for retrieving and caching iamges with a url.
public class CBPhotoFetcher: NSObject {
    
    /// If downloaded images should be cached to disk
    public var useDiskCache: Bool = true
    
    private var imageCache: NSCache! = NSCache()
    var inProgress: [String: CBImageFetchRequest]! = [:]
    let operationQueue = NSOperationQueue()
    let fm = NSFileManager.defaultManager()
    var networkCount = 0 {
        didSet { self.networdCountBlock?(change: oldValue - networkCount, total: self.networkCount) }
    }
    var networdCountBlock : CBNetworkActivityCountChangedBlock?
    
    private lazy var diskCacheURL: NSURL! = {
        let str = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let docs = NSURL(fileURLWithPath: str, isDirectory: true)
        return docs.URLByAppendingPathComponent("CBImageCache", isDirectory: true)
    }()
    
    /// Access the shared photofetcher to start or cancel download tasks
    public class var sharedFetcher : CBPhotoFetcher {
        struct Static {
            static let instance : CBPhotoFetcher = CBPhotoFetcher()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    public func setNetworkActivityBlock(block: CBNetworkActivityCountChangedBlock?) {
        self.networdCountBlock = block
    }
    
    // MARK: - Fetching Images
    
    /**
    Prefetch an image into cache
    
    - parameter imgUrl: The url to fetch
    */
    public func prefetchURL(imgUrl: String!) {
        let hash = imgUrl.cacheHash
        if inProgress[hash] != nil { return }
        imageFromCache(imgUrl) { (image) -> Void in
            if image != nil { return }
            let request = CBImageFetchRequest(imageURL: imgUrl, completion: nil, progress: nil)
            self.inProgress[hash] = request
            request.start()
        }
    }
    
    /**
     Fetch an image at the given url
     
     - parameter imgUrl:        The url for the image
     - parameter completion:    A completion handler when the download finishes
     - parameter progressBlock: A progress block for download updates
     */
    public func fetchImageAtURL(imgUrl: String!, completion: CBImageFetchCallback!, progressBlock: CBProgressBlock? = nil) {
        assert(completion != nil, "CBPhotoFetcher Error: You must suppy a completion block when loading an image")
        
        let hash = imgUrl.cacheHash
        
        imageFromCache(imgUrl) { (image) -> Void in
            if image != nil {
                completion(image: image, error: nil, fromCache: true)
                return
            }
            if let request = self.inProgress[hash] {
                request.completionBlocks.append(completion)
                if progressBlock != nil { request.progressBlocks.append(progressBlock!) }
                progressBlock?(progress: request.progress)
                return
            }
            let request = CBImageFetchRequest(imageURL: imgUrl, completion: completion, progress: progressBlock)
            self.inProgress[hash] = request
            request.start()
        }
    }
    
    
    // MARK: - Cancelling Requests
    
    /**
    Cancel all in progress image downloads
    */
    public func cancelAll() {
        for request in inProgress {
            request.1.cancelRequest()
        }
        inProgress.removeAll(keepCapacity: false)
    }
    public func cancelFetchForUrl(url: String) {
        if let request = inProgress[url] {
            request.cancelRequest()
        }
        inProgress.removeValueForKey(url)
    }
    
    
    // MARK: - Managing Cache
    
    /**
    Clear the image cache
    
    - parameter memory: Clear the memory cache
    - parameter disk:   Clear the disk cache
    */
    public func clearCache(memory: Bool = true, disk: Bool = true) {
        if memory {
            imageCache.removeAllObjects()
        }
        if disk {
            _ = try? fm.removeItemAtPath(diskCacheURL.path!)
            checkDiskCache()
        }
    }
    
    /**
     Clear memory and disk cache for a given url
     
     - parameter imgURL: The url to clear cache for
     */
    public func clearCacheForURL(imgURL: String) {
        imageCache.removeObjectForKey(imgURL.cacheHash)
        if let filePath = diskCacheURL.URLByAppendingPathComponent(imgURL.cacheHash).path {
            _ = try? fm.removeItemAtPath(filePath)
        }
    }
    
    
    // MARK: - Internal
    private func checkDiskCache() {
        if !fm.fileExistsAtPath(diskCacheURL.path!) {
            _ = try? fm.createDirectoryAtPath(diskCacheURL.path!, withIntermediateDirectories: true, attributes: nil)
            _ = try? diskCacheURL.setResourceValue(NSNumber(bool: true), forKey: NSURLIsExcludedFromBackupKey)
        }
    }
    
    func cacheImage(imgURL: String!, image: UIImage!, data: NSData) {
        operationQueue.addOperationWithBlock { () -> Void in
            let hash = imgURL.cacheHash
            self.imageCache.setObject(image, forKey: hash)
            if self.useDiskCache {
                self.checkDiskCache()
                let path = self.diskCacheURL.URLByAppendingPathComponent(hash)
                data.writeToFile(path.path!, atomically: true)
            }
        }
    }
    
    private func imageFromCache(imgURL: String, completion: (image: UIImage?)->Void) {
        let hash = imgURL.cacheHash
        if let cachedImage = imageCache.objectForKey(hash) as? UIImage  {
            completion(image: cachedImage)
            return
        }
        operationQueue.addOperationWithBlock { () -> Void in
            var img : UIImage?
            if let path = self.diskCacheURL.URLByAppendingPathComponent(hash).path {
                img = UIImage(contentsOfFile: path)
                if img != nil {
                    self.imageCache.setObject(img!, forKey: hash)
                }
            }
            dispatch_async(dispatch_get_main_queue(),{
                completion(image: img)
            })
        }
    }
    
}


protocol CBImageFetchRequestDelegate {
    func fetchRequestDidFinish(url: String, image: UIImage?)
}


class CBImageFetchRequest : NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate, NSURLSessionDelegate, NSURLSessionDownloadDelegate {
    
    var baseURL : String!
    var completionBlocks: [CBImageFetchCallback]! = []
    var progressBlocks : [CBProgressBlock]! = []
    
    var progress: Float = 0
    var sessionTask: NSURLSessionDownloadTask?
    
    init(imageURL: String!, completion: CBImageFetchCallback?, progress: CBProgressBlock? ) {
        super.init()
        baseURL = imageURL
        if completion != nil { completionBlocks = [completion!] }
        if progress != nil { progressBlocks = [progress!] }
    }
    
    func start() {
        let url = NSURL(string: baseURL)
        if url == nil {
            let err = NSError(domain: "CBToolkit", code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid url for image download"])
            for cBlock in completionBlocks {
                cBlock(image: nil, error: err, fromCache: false)
            }
            self.didFinish()
            return
        }
        
        let request = NSMutableURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 30)
        request.HTTPMethod = "GET"
        
        let sessionConfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        sessionTask = session.downloadTaskWithRequest(request)
        sessionTask!.resume()
    }
    
    func cancelRequest() {
        self.didFinish()
        sessionTask?.cancel()
        dispatch_async(dispatch_get_main_queue(),{
            for cBlock in self.completionBlocks {
                cBlock(image: nil, error: nil, fromCache: false)
            }
        })
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        dispatch_async(dispatch_get_main_queue(),{
            for pBlock in self.progressBlocks {
                pBlock(progress: self.progress)
            }
        })
    }
    
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        var error : NSError?
        var img : UIImage?
        
        if let imgData = NSData(contentsOfURL: location) {
            img = UIImage(data: imgData)
            if img != nil {
                CBPhotoFetcher.sharedFetcher.cacheImage(baseURL, image: img, data: imgData)
            }
        }
        if img == nil {
            error = NSError(domain: "CBToolkit", code: 2, userInfo: [NSLocalizedDescriptionKey : "Could not procress image data into image."])
        }
        self.didFinish()
        dispatch_async(dispatch_get_main_queue(),{
            for cBlock in self.completionBlocks {
                cBlock(image: img, error: error, fromCache: false)
            }
        })
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            dispatch_async(dispatch_get_main_queue(),{
                for cBlock in self.completionBlocks {
                    cBlock(image: nil, error: error, fromCache: false)
                }
                self.didFinish()
                debugPrint("CBPhotoFetcher: Fetch error – \(error!.localizedDescription)")
            })
        }
    }
    
    func didFinish() {
        CBPhotoFetcher.sharedFetcher.inProgress.removeValueForKey(baseURL.cacheHash)
    }
}


extension String {
    
    var cacheHash: String {
        let url = self
        
        var hash: UInt32 = 0
        for (index, codeUnit) in url.utf8.enumerate() {
            hash += (UInt32(codeUnit) * UInt32(index))
            hash ^= (hash >> 6)
        }
        hash += (hash << 3)
        hash ^= (hash >> 11)
        hash += (hash << 15)
        
        if let fileExtension = NSURL(string: self)?.pathExtension {
            return "\(hash).\(fileExtension)"
        }
        return "\(hash)"
    }
    
}






