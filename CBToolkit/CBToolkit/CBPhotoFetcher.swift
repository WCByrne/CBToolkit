//
//  CBPhotoFetcher.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/6/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


public typealias CBImageFetchCallback = (_ image: UIImage?, _ error: Error?, _ fromCache: Bool)->Void
public typealias CBProgressBlock = (_ progress: Float)->Void
public typealias CBNetworkActivityCountChangedBlock = (_ change: Int, _ total: Int)->Void

/// An image fetching util for retrieving and caching iamges with a url.
public class CBPhotoFetcher: NSObject {
    
    /// If downloaded images should be cached to disk
    public var useDiskCache: Bool = true
    
    private var imageCache: NSCache! = NSCache<AnyObject,AnyObject>()
    var inProgress: [String: CBImageFetchRequest]! = [:]
    let operationQueue = OperationQueue()
    let fm = FileManager.default
    var networkCount = 0 {
        didSet { self.networdCountBlock?(oldValue - networkCount, self.networkCount) }
    }
    var networdCountBlock : CBNetworkActivityCountChangedBlock?
    
    private lazy var diskCacheURL: URL! = {
        
        let str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let docs = NSURL(fileURLWithPath: str, isDirectory: true)
        return docs.appendingPathComponent("CBImageCache", isDirectory: true)
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
        operationQueue.maxConcurrentOperationCount = 6
    }
    
    public func setNetworkActivityBlock(block: CBNetworkActivityCountChangedBlock?) {
        self.networdCountBlock = block
    }
    
    // MARK: - Fetching Images
    
    /**
    Prefetch an image into cache
    
    - parameter imgUrl: The url to fetch
    */
    public func prefetch(url: String!) {
        let hash = url.cacheHash
        if inProgress[hash] != nil { return }
        imageFromCache(url) { (image) -> Void in
            if image != nil { return }
            let request = CBImageFetchRequest(imageURL: url, completion: nil, progress: nil)
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
    public func fetchImage(at url: String!, completion: CBImageFetchCallback!, progressBlock: CBProgressBlock? = nil) {
        assert(completion != nil, "CBPhotoFetcher Error: You must suppy a completion block when loading an image")
        
        let hash = url.cacheHash
        
        imageFromCache(url) { (image) -> Void in
            if image != nil {
                completion(image, nil, true)
                return
            }
            if let request = self.inProgress[hash] {
                request.completionBlocks.append(completion)
                if progressBlock != nil { request.progressBlocks.append(progressBlock!) }
                progressBlock?(request.progress)
                return
            }
            let request = CBImageFetchRequest(imageURL: url, completion: completion, progress: progressBlock)
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
        inProgress.removeAll(keepingCapacity: false)
    }
    public func cancelFetch(for url: String) {
        if let request = inProgress[url] {
            request.cancelRequest()
        }
        inProgress.removeValue(forKey: url)
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
            _ = try? fm.removeItem(at: diskCacheURL)
            checkDiskCache()
        }
    }
    
    /**
     Clear memory and disk cache for a given url
     
     - parameter imgURL: The url to clear cache for
     */
    public func clearCache(for url: String) {
        imageCache.removeObject(forKey: url.cacheHash as NSString)
        do {
            let filePath = diskCacheURL.appendingPathComponent(url.cacheHash)
            _ = try fm.removeItem(at: filePath)
        }
        catch _ {
            
        }
    }
    
    
    // MARK: - Internal
    private func checkDiskCache() {
        
        if !fm.fileExists(atPath:diskCacheURL.path) {
            _ = try? fm.createDirectory(at: diskCacheURL, withIntermediateDirectories: true, attributes: nil)
            diskCacheURL.setTemporaryResourceValue(true, forKey: URLResourceKey.isExcludedFromBackupKey)
        }
    }
    
    func cacheImage(imgURL: String!, image: UIImage!, data: Data) {
        operationQueue.addOperation { () -> Void in
            let hash = imgURL.cacheHash
            self.imageCache.setObject(image, forKey: hash as NSString)
            if self.useDiskCache {
                self.checkDiskCache()
                let path = self.diskCacheURL.appendingPathComponent(hash)
                do {
                    try data.write(to: path)
                }
                catch _ { }
            }
        }
    }
    
    private func imageFromCache(_ imgURL: String, completion: @escaping (_ image: UIImage?)->Void) {
        let hash = imgURL.cacheHash
        if let cachedImage = imageCache.object(forKey: hash  as NSString) as? UIImage  {
            completion(cachedImage)
            return
        }
        operationQueue.addOperation { () -> Void in
            var img : UIImage?
                let path = self.diskCacheURL.appendingPathComponent(hash).path
                img = UIImage(contentsOfFile: path)
                if img != nil {
                    self.imageCache.setObject(img!, forKey: hash  as NSString)
                }
                DispatchQueue.main.async(execute: {
                    completion(img)
                })
        }
    }
    
}


protocol CBImageFetchRequestDelegate {
    func fetchRequestDidFinish(url: String, image: UIImage?)
}


class CBImageFetchRequest : NSObject, NSURLConnectionDelegate, NSURLConnectionDataDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var baseURL : String!
    var completionBlocks: [CBImageFetchCallback]! = []
    var progressBlocks : [CBProgressBlock]! = []
    
    var progress: Float = 0
    var sessionTask: URLSessionDownloadTask?
    
    init(imageURL: String!, completion: CBImageFetchCallback?, progress: CBProgressBlock? ) {
        super.init()
        baseURL = imageURL
        if completion != nil { completionBlocks = [completion!] }
        if progress != nil { progressBlocks = [progress!] }
    }
    
    func start() {
        guard let url = URL(string: baseURL) else {
            let err = NSError(domain: "CBToolkit", code: 100, userInfo: [NSLocalizedDescriptionKey: "Invalid url for image download"])
            for cBlock in completionBlocks {
                cBlock(nil, err, false)
            }
            self.didFinish()
            return
        }
        
        
        var request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: nil)
        sessionTask = session.downloadTask(with: request)
        sessionTask!.resume()
    }
    
    func cancelRequest() {
        self.didFinish()
        sessionTask?.cancel()
        DispatchQueue.main.async(execute: {
            for cBlock in self.completionBlocks {
                cBlock(nil, nil, false)
            }
        })
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        
    }
    

    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async(execute: {
            for pBlock in self.progressBlocks {
                pBlock(self.progress)
            }
        })

    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        var error : NSError?
        var img : UIImage?
        
        var imgData : Data
        do {
            try imgData = Data(contentsOf: location)
            img = UIImage(data: imgData)
            if img != nil {
                CBPhotoFetcher.sharedFetcher.cacheImage(imgURL: baseURL, image: img, data: imgData)
            }
        }
        catch { }
        
        if img == nil {
            error = NSError(domain: "CBToolkit", code: 2, userInfo: [NSLocalizedDescriptionKey : "Could not procress image data into image."])
        }
        self.didFinish()
        DispatchQueue.main.async(execute: {
            for cBlock in self.completionBlocks {
                cBlock(img, error, false)
            }
        })
    }


    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            DispatchQueue.main.async(execute: {
                for cBlock in self.completionBlocks {
                    cBlock(nil, error, false)
                }
                self.didFinish()
                debugPrint("CBPhotoFetcher: Fetch error – \(error!.localizedDescription)")
            })
        }
    }
    
    
    func didFinish() {
        CBPhotoFetcher.sharedFetcher.inProgress.removeValue(forKey: baseURL.cacheHash)
    }
}


extension String {
    
    var cacheHash: String {
        let url = self
        
        var hash: UInt32 = 0
        for (index, codeUnit) in url.utf8.enumerated() {
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






