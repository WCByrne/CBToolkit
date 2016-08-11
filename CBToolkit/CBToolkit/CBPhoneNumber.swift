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
            
            let comps = NSArray(array: string.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
            baseString = comps.componentsJoined(by: "")
        }
    }
    
    /**
     Append a string to the phone number. Non numberic characters will be removed.
     
     - parameter string: The string to append.
     */
    public func appendString(string: String!) {
        let comps = NSArray(array: string.components(separatedBy: NSCharacterSet.decimalDigits.inverted))
        let addedString = comps.componentsJoined(by: "")
        baseString = baseString.appending(addedString)
    }
    
    
    /**
     Remove the last number from the phone number
     */
    public func removeLastCharacter() {
        if baseString.length > 0 {
            baseString = baseString.substring(to: baseString.length-1)
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
        
        var  prefix: String? = baseString.substring(to: 1)
        var string: NSString! = baseString
        if prefix != "1" {
            prefix = nil
        }
        else {
            string = baseString.substring(from: 1)
        }
        
        let length = string.length
        if length <= 3 {
            if length > 0 && prefix != nil {
                string = "(\(string))"
            }
        }
        else if length <= 7  {
            let firstThree = string.substring(to: 3)
            var partial = string.substring(with: NSMakeRange(3, length-3)) as NSString
            
            if prefix != nil{
                if partial.length == 4 {
                    partial = "\(partial.substring(to: 3))-\(partial.substring(from: 3))"
                }
                
                string = "(\(firstThree)) \(partial)"
            }
            else {
                string = "\(firstThree)-\(partial)"
            }
        }
        else if length <= 10 {
            let areaCode = string.substring(to: 3)
            let firstThree = string.substring(with: NSMakeRange(3, 3))
            let lastFour = string.substring(with: NSMakeRange(6, length-6))
            
            string = "(\(areaCode)) \(firstThree)-\(lastFour)"
        }
        else {
            let prefix = string.substring(to: length-10)
            let areaCode = string.substring(with: NSMakeRange(length-10, 3))
            let firstThree = string.substring(with: NSMakeRange(length-7, 3))
            let lastFour = string.substring(with: NSMakeRange(length-4, 4))
            
            string = "+\(prefix) (\(areaCode)) \(firstThree)-\(lastFour)"
        }
        
        if prefix != nil {
            string = "+\(prefix!) \(string)"
        }
        
        return string.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    
    /**
     Invoke the system to call the phone number.
     
     - returns: True if the system can call the number otherwise false.
     */
    public func callNumber() -> Bool {
        let phoneURL : NSURL = NSURL(string:"telprompt:\(baseString)")!
        if UIApplication.shared.canOpenURL(phoneURL as URL) {
            UIApplication.shared.openURL(phoneURL as URL)
            return true
        }
        return false
    }
    
    
    
    
}
