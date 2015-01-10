//
//  CBPhoneNumber.swift
//  CBToolkit
//
//  Created by Wes Byrne on 1/9/15.
//  Copyright (c) 2015 WCBMedia. All rights reserved.
//

import Foundation


class CBPhoneNumber {
    
    private var baseString: NSString! = NSString()
    var numericString: String! {
        get {
            return baseString
        }
    }
    

    init(string : String?) {
        if string != nil {
            var string = NSString(string: string!)
            
            var comps = NSArray(array: string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
            baseString = comps.componentsJoinedByString("")
        }
    }
    
    
    func appendString(string: String!) {
        var comps = NSArray(array: string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
        var addedString = comps.componentsJoinedByString("")
        baseString = baseString.stringByAppendingString(addedString)
    }
    
    
    func removeLastCharacter() {
        if baseString.length > 0 {
            baseString = baseString.substringToIndex(baseString.length-1)
        }
    }
    
    
    func isPatiallyValid() -> Bool {
        return baseString.length <= 11
        
    }
    
    
    func isValid() -> Bool {
        let length = baseString.length
        return (length == 7 || length >= 10)
    }
    
    
    func formattedNumber() -> String! {
        
        if baseString.length == 0 {
            return baseString
        }
        else if baseString.length > 11 {
            return baseString
        }
        
        var  prefix: String? = baseString.substringToIndex(1)
        var string: NSString! = baseString
        if prefix != "1" {
            prefix = nil
        }
        else {
            string = baseString.substringFromIndex(1)
        }
        
        let length = string.length
        if length <= 3 {
            if length > 0 && prefix != nil {
                string = "(\(string))"
            }
        }
        else if length <= 7  {
            var firstThree = string.substringToIndex(3)
            var partial = string.substringWithRange(NSMakeRange(3, length-3)) as NSString
            
            if prefix != nil{
                if partial.length == 4 {
                    partial = "\(partial.substringToIndex(3))-\(partial.substringFromIndex(3))"
                }
                
                string = "(\(firstThree)) \(partial)"
            }
            else {
                string = "\(firstThree)-\(partial)"
            }
        }
        else if length <= 10 {
            var areaCode = string.substringToIndex(3)
            var firstThree = string.substringWithRange(NSMakeRange(3, 3))
            var lastFour = string.substringWithRange(NSMakeRange(6, length-6))
            
            string = "(\(areaCode)) \(firstThree)-\(lastFour)"
        }
        else {
            var prefix = string.substringToIndex(length-10)
            var areaCode = string.substringWithRange(NSMakeRange(length-10, 3))
            var firstThree = string.substringWithRange(NSMakeRange(length-7, 3))
            var lastFour = string.substringWithRange(NSMakeRange(length-4, 4))
            
            string = "+\(prefix) (\(areaCode)) \(firstThree)-\(lastFour)"
        }
        
        if prefix != nil {
            string = "+\(prefix!) \(string)"
        }
        
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    
    
    
}