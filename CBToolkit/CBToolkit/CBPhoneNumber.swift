//
//  CBPhoneNumber.swift
//  CBToolkit
//
//  Created by Wes Byrne on 1/9/15.
//  Copyright (c) 2015 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


/// A utitility class for validating and formatting phone numbers
public class CBPhoneNumber {
    
    private var baseString: NSString! = NSString()
    /// The numeric string of the phone number
    public var numericString: String! {
        get { return baseString as String }
    }
    
    /// Returns true if the phone number is a partially valid phone number
    public var isPartiallyValid: Bool {
        get { return baseString.length <= 1 }
    }
    
    /// True if the phone number is valid length phone number
    public var isValid : Bool {
        let length = baseString.length
        return (length == 7 || length >= 10)
    }
    
    /**
     Initialize a CBPhoneNumber with a string. Non numberic characters will be removed.
     
     - parameter string: A string containing a phone number
     - returns: A new CBPhoneNumber
     */
    public init(string : String?) {
        if string != nil {
            let string = NSString(string: string!)
            
            let comps = NSArray(array: string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
            baseString = comps.componentsJoinedByString("")
        }
    }
    
    /**
     Append a string to the phone number. Non numberic characters will be removed.
     
     - parameter string: The string to append.
     */
    public func appendString(string: String!) {
        let comps = NSArray(array: string.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet().invertedSet))
        let addedString = comps.componentsJoinedByString("")
        baseString = baseString.stringByAppendingString(addedString)
    }
    
    
    /**
     Remove the last number from the phone number
     */
    public func removeLastCharacter() {
        if baseString.length > 0 {
            baseString = baseString.substringToIndex(baseString.length-1)
        }
    }
    
    /**
     A formatted phone number for the available string
     
     - returns: A formatted phone number. This can be partial
     */
    public func formattedNumber() -> String! {
        
        if baseString.length == 0 {
            return baseString as String
        }
        else if baseString.length > 11 {
            return baseString as String
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
            let firstThree = string.substringToIndex(3)
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
            let areaCode = string.substringToIndex(3)
            let firstThree = string.substringWithRange(NSMakeRange(3, 3))
            let lastFour = string.substringWithRange(NSMakeRange(6, length-6))
            
            string = "(\(areaCode)) \(firstThree)-\(lastFour)"
        }
        else {
            let prefix = string.substringToIndex(length-10)
            let areaCode = string.substringWithRange(NSMakeRange(length-10, 3))
            let firstThree = string.substringWithRange(NSMakeRange(length-7, 3))
            let lastFour = string.substringWithRange(NSMakeRange(length-4, 4))
            
            string = "+\(prefix) (\(areaCode)) \(firstThree)-\(lastFour)"
        }
        
        if prefix != nil {
            string = "+\(prefix!) \(string)"
        }
        
        return string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    
    /**
     Invoke the system to call the phone number.
     
     - returns: True if the system can call the number otherwise false.
     */
    public func callNumber() -> Bool {
        let phoneURL : NSURL = NSURL(string:"telprompt:\(baseString)")!
        if UIApplication.sharedApplication().canOpenURL(phoneURL) {
            UIApplication.sharedApplication().openURL(phoneURL)
            return true
        }
        return false
    }
    
    
    
    
}