//
//  CBPhotoFetcher.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/6/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit

/*
public typealias CBImageFetchCallback = (_ image: UIImage?, _ error: Error?, _ fromCache: Bool)->Void
public typealias CBProgressBlock = (_ progress: Float)->Void
public typealias CBNetworkActivityCountChangedBlock = (_ change: Int, _ total: Int)->Void

/// An image fetching util for retrieving and caching iamges with a url.
public class CBPhotoFetcher: NSObject {
    
    /// If downloaded images should be cached to disk
    public var useDiskCache: Bool = true
    
    private var imageCache: NSCache! = NSCache<AnyObject,AnyObject>()
    var inProgress: [URL: CBImageFetchRequest]! = [:]
    let operationQueue = OperationQueue()
    let downloadQueue = OperationQueue()
    let fetcherQueue = OperationQueue()
    
    let fm = FileManager()
    var networkCount = 0 {
        didSet { self.networdCountBlock?(oldValue - networkCount, self.networkCount) }
    }
    var networdCountBlock : CBNetworkActivityCountChangedBlock?
    
    private lazy var diskCacheURL: URL! = {
        let str = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] // NSTemporaryDirectory()
        let docs =  NSURL(fileURLWithPath: str, isDirectory: true)
        return docs.appendingPathComponent("CBImageCache", isDirectory: true)
    }()
    
    deinit {
        self.downloadQueue.cancelAllOperations()
        self.operationQueue.cancelAllOperations()
    }
    
    /// Access the shared photofetcher to start or cancel download tasks
    public class var shared : CBPhotoFetcher {
        struct Static {
            static let instance : CBPhotoFetcher = CBPhotoFetcher()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
        self.downloadQueue.maxConcurrentOperationCount = 1
        self.operationQueue.maxConcurrentOperationCount = 5
        self.checkDiskCache()
    }
    
    public func setNetworkActivityBlock(block: CBNetworkActivityCountChangedBlock?) {
        self.networdCountBlock = block
    }
    
    // MARK: - Fetching Images
    
    /**
    Prefetch an image into cache
    
    - parameter imgUrl: The url to fetch
    */
    public func prefetch(for url: URL!) {
//        let hash = imgUrl.cacheHash
        if inProgress[url] != nil { return }
        
        operationQueue.addOperation {
            if self.imageFromCache(url) != nil {
                return
            }
            let request = CBImageFetchRequest(url: url, completion: nil, progress: nil)
            self.inProgress[url] = request
            self.downloadQueue.addOperation(request)
        }
    }
    
    /**
     Fetch an image at the given url
     
     - parameter imgUrl:        The url for the image
     - parameter completion:    A completion handler when the download finishes
     - parameter progressBlock: A progress block for download updates
     */
    public func fetchImage(at url: URL!, completion: CBImageFetchCallback!, progressBlock: CBProgressBlock? = nil) {
        assert(completion != nil, "CBPhotoFetcher Error: You must suppy a completion block when loading an image")
        
        operationQueue.addOperation {
            
            if let cacheResult = self.imageFromCache(url) {
                DispatchQueue.main.async(execute: {
                    completion(cacheResult, nil, true)
                })
                return
            }
            
            if let request = self.inProgress[url] {
                request.completionBlocks.append(completion)
                if let pBlock = progressBlock {
                    request.progressBlocks.append(progressBlock!)
                    DispatchQueue.main.async(execute: {
                        pBlock(request.progress)
                    })
                }
                return
            }
            let request = CBImageFetchRequest(url: url, completion: completion, progress: progressBlock)
            self.inProgress[url] = request
            self.downloadQueue.addOperation(request)
        }
    }
    
    
    // MARK: - Cancelling Requests
    
    /**
    Cancel all in progress image downloads
    */
    public func cancelAll() {
        downloadQueue.cancelAllOperations()
        inProgress.removeAll(keepingCapacity: false)
    }
    public func cancelFetch(for url: URL) {
        if let request = inProgress[url] {
            request.cancel()
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
            do {
                try fm.removeItem(at: diskCacheURL)
            }
            catch let err {
                print("clear disk cache error: \(err)")
            }
            checkDiskCache()
        }
    }
    
    /**
     Clear memory and disk cache for a given url
     
     - parameter imgURL: The url to clear cache for
     */
    public func clearCache(for url: URL) {
        let hash = url.cacheHash
        imageCache.removeObject(forKey: hash as AnyObject)
        do {
            let filePath = diskCacheURL.appendingPathComponent(hash)
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
    
    
    func cache(imageData: Data, for url: URL) {
        let hash = url.cacheHash
        if self.useDiskCache {
            let path = self.diskCacheURL.appendingPathComponent(hash)
            do {
                _ = try? fm.removeItem(at: path)
                try imageData.write(to: path)
            }
            catch let err {
                print("Cache Image Data Error : \(err)")
            }
        }
    }
    
    func cacheImage(at fileURL: URL!, for remoteURL: URL) -> URL? {
        if self.useDiskCache {
            let hash = remoteURL.cacheHash
            let cacheURL = self.diskCacheURL.appendingPathComponent(hash)
            do {
                _ = try? fm.removeItem(at: cacheURL)
                try fm.moveItem(at: fileURL, to: cacheURL)
                return cacheURL
            }
            catch let err {
                print("Cache imageAt: Error: \(err)")
            }
        }
        return nil
    }
    
    func cache(image: UIImage!, for url: URL!) {
        let hash = url.cacheHash
        self.imageCache.setObject(image, forKey: hash as AnyObject)
    }
    
    func fileURL(forRemoteURL url: URL) -> URL? {
        let hash = url.cacheHash
        let url = self.diskCacheURL.appendingPathComponent(hash)
        return url
    }
    
    private func imageFromCache(_ url: URL) -> UIImage? {
        let hash = url.cacheHash
        if let cachedImage = imageCache.object(forKey: hash as AnyObject) as? UIImage  {
            return cachedImage
        }
        var img : UIImage?
        let path = self.diskCacheURL.appendingPathComponent(hash).path
        img = UIImage(contentsOfFile: path)
        if img != nil {
            self.imageCache.setObject(img!, forKey: hash as AnyObject)
        }
        return img
    }
    
}


class CBImageFetchRequest : AsyncOperation, NSURLConnectionDelegate, NSURLConnectionDataDelegate, URLSessionDelegate, URLSessionDownloadDelegate {
    
    var baseURL : URL!
    var completionBlocks: [CBImageFetchCallback]! = []
    var progressBlocks : [CBProgressBlock]! = []
    
    var progress: Float = 0
    var sessionTask: URLSessionDownloadTask?
    
    init(url: URL!, completion: CBImageFetchCallback?, progress: CBProgressBlock? ) {
        super.init()
        baseURL = url
        if completion != nil { completionBlocks = [completion!] }
        if progress != nil { progressBlocks = [progress!] }
    }
    
    override func start() {
        
        self.isExecuting = true
        if self.isCancelled {
            self._finished = true
            return
        }
        print("STARTING: \(baseURL)")
        
        var request = URLRequest(url: baseURL, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 30)
        request.httpMethod = "GET"
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
        sessionTask = session.downloadTask(with: request)
        sessionTask!.resume()
    }
    
    override func cancel() {
        super.cancel()
        self.sessionTask?.cancel()
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
        let error : NSError? = nil
        var img : UIImage? = nil
        let fetcher = CBPhotoFetcher.shared
        
        if let response = downloadTask.response as? HTTPURLResponse, response.allHeaderFields["Content-Type"] as? String == "image/png" {
            if let url = fetcher.cacheImage(at: location, for: baseURL), let i = UIImage(contentsOfFile: url.path) {
                img = i
                fetcher.cache(image: i, for: baseURL)
            }
        }
        
        DispatchQueue.main.async(execute: {
            for cBlock in self.completionBlocks {
                cBlock(img, error, false)
            }
        })
        self.didFinish()
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
        CBPhotoFetcher.shared.inProgress.removeValue(forKey: baseURL)
        self.isExecuting = false
        self.isFinished = true
    }
}


extension URL {
    
    var cacheHash: String {
        
        return self.lastPathComponent
        
        
        let url = self.absoluteString
        
        var hash: UInt32 = 0
        for (index, codeUnit) in url.utf8.enumerated() {
            hash += (UInt32(codeUnit) * UInt32(index))
            hash ^= (hash >> 6)
        }
        hash += (hash << 3)
        hash ^= (hash >> 11)
        hash += (hash << 15)
        
        let ext = self.pathExtension
        if !ext.isEmpty {
            return "\(hash).\(ext)"
        }
        return "\(hash)"
        
//        let url = self.absoluteString
//        
//        let str = url.cString(using: .utf8)
//        let strLen = CUnsignedInt(url.lengthOfBytes(using: .utf8))
//        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
//        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
//        
//        CC_MD5(str!, strLen, result)
//        
//        var hash : String = ""
//        for i in 0..<digestLen {
//            hash = hash.appendingFormat("%02x", result[i])
//        }
//        
//        result.deinitialize()
//        
//        return hash
    }
    
}





class AsyncOperation: Operation {
    // This class changes isExecuting and isFinished to be settable and to send KVO notifications.
    
    fileprivate var _executing = false
    fileprivate var _finished = false
    
    override var isAsynchronous: Bool {
        return true
    }
    
    override var isConcurrent: Bool {
        return true
    }
    
    override var isExecuting: Bool {
        get {
            return self._executing
        }
        set(value) {
            self.willChangeValue(forKey: "isExecuting")
            self._executing = value
            self.didChangeValue(forKey: "isExecuting")
        }
    }
    override var isFinished: Bool {
        get {
            return self._finished
        }
        set(value) {
            self.willChangeValue(forKey:"isFinished")
            self._finished = value
            self.didChangeValue(forKey: "isFinished")
        }
    }
}
*/


