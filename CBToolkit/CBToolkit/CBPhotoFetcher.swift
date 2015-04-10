//
//  CBPhotoFetcher.swift
//  CBToolkit
//
//  Created by Wes Byrne on 12/6/14.
//  Copyright (c) 2014 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


public typealias CBImageFetchCallback = (image: UIImage?, error: NSError?)->Void


public class CBPhotoFetcher: NSObject {
    
    private var imageCache: NSCache! = NSCache()
    private var pendingFetches: [String: [CBImageFetchCallback]]! = [:]
    
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
        pendingFetches.removeAll(keepCapacity: false)
    }
    
    // Clears any callbacks for the url
    // The image will continue to load and cache for next time
    public func cancelFetchForUrl(url: String) {
        pendingFetches.removeValueForKey(url)
    }
    
    public func fetchImageAtURL(imgUrl: String, completion: CBImageFetchCallback!) {
        
        assert(completion != nil, "CBPhotoFetcher Error: You must suppy a completion block when loading an image")
        
        if let cachedImage = imageCache.objectForKey(imgUrl) as? UIImage  {
            completion(image: cachedImage, error: nil)
            return
        }
        
        if (pendingFetches[imgUrl] != nil) {
            var existingCallbacks = self.pendingFetches[imgUrl]!
            existingCallbacks.append(completion)
            return
        }
        
        
        var url = NSURL(string: imgUrl)
        if url == nil {
            println("Error creating URL for image url: \(imgUrl)")
            completion(image: nil, error: NSError(domain: "SmartReader", code: 0, userInfo: nil))
            return
        }
        
        pendingFetches[imgUrl] = [completion]
        
        var request = NSURLRequest(URL: url!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
            var image: UIImage? = nil
            var urlStr = request.URL!.absoluteString!
            
            if (error == nil) {
                image = UIImage(data: data)
                self.imageCache.setObject(image!, forKey: urlStr)
            }
            
            var callbacks = self.pendingFetches[urlStr]
            if (callbacks == nil) {
                println("callback not found after fetch for url: \(urlStr)")
                return
            }
            
            for cb in callbacks! {
                cb(image: image, error: error)
            }
            self.pendingFetches.removeValueForKey(urlStr)
        }
        
    }
    
    
    
}