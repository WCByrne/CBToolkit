//
//  CBPhotoFetcher.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/6/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


public typealias CBImageFetchCallback = (image: UIImage?, error: NSError?, requestTime: NSTimeInterval)->Void
public typealias CBProgressBlock = (progress: Float)->Void


public class CBPhotoFetcher: NSObject, CBImageFetchRequestDelegate {
    
    private var imageCache: NSCache! = NSCache()
    private var inProgress: [String: CBImageFetchRequest]! = [:]
    
    public class var sharedFetcher : CBPhotoFetcher {
        struct Static {
            static let instance : CBPhotoFetcher = CBPhotoFetcher()
        }
        return Static.instance
    }
    
    override init() {
        super.init()
    }
    
    public func clearCache() {
        imageCache.removeAllObjects()
    }
    
    public func cancelAll() {
        inProgress.removeAll(keepCapacity: false)
    }
    
    public func cacheForURL(imgUrl: String) -> UIImage? {
        if let cachedImage = imageCache.objectForKey(imgUrl) as? UIImage  {
            return cachedImage
        }
        return nil
    }
    
    public func clearCacheForURL(imgURL: String) {
        imageCache.removeObjectForKey(imgURL)
    }
    
    public func insertCacheImage(imgURL: String!, image: UIImage!) {
        imageCache.setObject(image, forKey: imgURL)
    }
    
    // Clears any callbacks for the url
    // The image will continue to load and cache for next time
    public func cancelFetchForUrl(url: String) {
        if let request = inProgress[url] {
            request.cancelRequest()
        }
        inProgress.removeValueForKey(url)
    }
    
    public func prefetchURL(imgUrl: String!) {
        if imageCache.objectForKey(imgUrl) != nil  {
            return
        }
        if inProgress[imgUrl] != nil {
            return
        }
        let request = CBImageFetchRequest(imageURL: imgUrl, completion: nil, progress: nil)
        inProgress[imgUrl] = request
        request.delegate = self
        request.start()
    }
    
    public func fetchImageAtURL(imgUrl: String!, completion: CBImageFetchCallback!, progressBlock: CBProgressBlock? = nil) {
        assert(completion != nil, "CBPhotoFetcher Error: You must suppy a completion block when loading an image")
        
        // The image is chached
        if let cachedImage = imageCache.objectForKey(imgUrl) as? UIImage  {
            completion(image: cachedImage, error: nil, requestTime: 0)
            return
        }
        
        // A request is already going. add it on
        if let request = inProgress[imgUrl] {
            request.completionBlocks.append(completion)
            if progressBlock != nil { request.progressBlocks.append(progressBlock!) }
            progressBlock?(progress: request.progress)
            return
        }
        
        let request = CBImageFetchRequest(imageURL: imgUrl, completion: completion, progress: progressBlock)
        inProgress[imgUrl] = request
        request.delegate = self
        request.start()
    }
    
    func fetchRequestDidFinish(url: String, image: UIImage?) {
        inProgress.removeValueForKey(url)
        if image != nil {
            imageCache.setObject(image!, forKey: url)
        }
        else {
            imageCache.removeObjectForKey(url)
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
    var startDate = NSDate()
    
    var delegate : CBImageFetchRequestDelegate!
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
                cBlock(image: nil, error: err, requestTime: 0)
            }
            self.delegate.fetchRequestDidFinish(baseURL, image: nil)
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
        sessionTask?.cancel()
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
        }
        if img == nil {
            error = NSError(domain: "CBToolkit", code: 2, userInfo: [NSLocalizedDescriptionKey : "Could not procress image data into image."])
        }
        dispatch_async(dispatch_get_main_queue(),{
            for cBlock in self.completionBlocks {
                cBlock(image: img, error: error, requestTime: self.startDate.timeIntervalSinceNow)
            }
            self.delegate.fetchRequestDidFinish(self.baseURL, image: img)
        })
    }
    
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        if error != nil {
            dispatch_async(dispatch_get_main_queue(),{
                for cBlock in self.completionBlocks {
                    cBlock(image: nil, error: error, requestTime: self.startDate.timeIntervalSinceNow)
                }
                self.delegate.fetchRequestDidFinish(self.baseURL, image: nil)
                debugPrint("CBPhotoFetcher: Fetch error – \(error!.localizedDescription)")
            })
        }
    }
}






