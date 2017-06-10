//
//  CBPhoneNumber.swift
//  CBToolkit
//
//  Created by Wes Byrne on 1/9/15.
//  Copyright (c) 2015 WCBMedia. All rights reserved.
//

import Foundation
import UIKit


extension String {
    
    var numericString : String {
        let set = CharacterSet(charactersIn: "0123456789.")
        return self.stringByValidatingCharactersInSet(set)
    }
    
    func stringByValidatingCharactersInSet(_ set: CharacterSet) -> String {
        let comps = self.components(separatedBy: set.inverted)
        return comps.joined(separator: "")
    }
    
    func sub(to: Int) -> String {
        let idx = self.index(self.startIndex,
                             offsetBy: to)
        return self.substring(to: idx)
    }
    
    func sub(from: Int) -> String {
        let idx = self.index(self.startIndex,
                             offsetBy: from)
        return self.substring(from: idx)
    }
    
    func sub(from: Int, to: Int) -> String {
        let start = self.index(self.startIndex, offsetBy: from)
        let end = self.index(self.startIndex, offsetBy: to)
        return String(self[start..<end])
    }
    
}


/// A utitility class for validating and formatting phone numbers
public class CBPhoneNumber {
    
    fileprivate var baseString: String = ""
    /// The numeric string of the phone number
    public var numericString: String! {
        get { return baseString as String }
    }
    
    /// Returns true if the phone number is a partially valid phone number
    open var isPartiallyValid: Bool {
        get { return baseString.characters.count <= 1 }
    }
    
    /// True if the phone number is valid length phone number
    open var isValid : Bool {
        let length = baseString.characters.count
        return (length == 7 || length >= 10)
    }
    
    
    /**
     Initialize a CBPhoneNumber with a string. Non numberic characters will be removed.
     
     - parameter string: A string containing a phone number
     - returns: A new CBPhoneNumber
     */
    public init(string : String?) {
        if let str = string {
            
            let comps = str.components(separatedBy: CharacterSet.decimalDigits.inverted)
            baseString = comps.joined(separator: "")
        }
    }
    
    /**
     Append a string to the phone number. Non numberic characters will be removed.
     
     - parameter string: The string to append.
     */
    public func append(_ string: String) {
        let comps = NSArray(array: string.components(separatedBy: CharacterSet.decimalDigits.inverted))
        let addedString = comps.componentsJoined(by: "")
        baseString = baseString.appending(addedString)
    }
    
    
    /**
     Remove the last number from the phone number
     */
    public func removeLast() {
        if baseString.characters.count > 0 {
            baseString = baseString.sub(to: baseString.characters.count-1)
        }
    }
    
    /**
     A formatted phone number for the available string
     
     - returns: A formatted phone number. This can be partial
     */
    open var formattedString : String {
        
        if baseString.characters.count == 0 {
            return baseString
        }
        else if baseString.characters.count > 11 {
            return baseString
        }
        
        var  prefix: String? = baseString.sub(to: 1)
        var string = baseString
        if prefix != "1" {
            prefix = nil
        }
        else {
            string = baseString.sub(from: 1)
        }
        
        let length = string.characters.count
        if length <= 3 {
            if length > 0 && prefix != nil {
                string = "(\(string))"
            }
        }
        else if length <= 7  {
            let firstThree = string.sub(to: 3)
            var partial = string.sub(from: 3,  to: length-3)
            
            if prefix != nil{
                if partial.characters.count == 4 {
                    partial = "\(partial.sub(to: 3))-\(partial.sub(from: 3))"
                }
                
                string = "(\(firstThree)) \(partial)"
            }
            else {
                string = "\(firstThree)-\(partial)"
            }
        }
        else if length <= 10 {
            let areaCode = string.sub(to: 3)
            let firstThree = string.sub(from: 3, to: 6)
            let lastFour = string.sub(from: 6, to: length-6)
            
            string = "(\(areaCode)) \(firstThree)-\(lastFour)"
        }
        else {
            let prefix = string.sub(to: length-10)
            let areaCode = string.sub(from: length-10, to : length - 7)
            let firstThree = string.sub(from: length-7, to: length - 10)
            let lastFour = string.sub(from: length-4)
            
            string = "+\(prefix) (\(areaCode)) \(firstThree)-\(lastFour)"
        }
        
        if prefix != nil {
            string = "+\(prefix!) \(string)"
        }
        
        return string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    
    /**
     Invoke the system to call the phone number.
     
     - returns: True if the system can call the number otherwise false.
     */
    public func call() -> Bool {
        let phoneURL : NSURL = NSURL(string:"telprompt:\(baseString)")!
        if UIApplication.shared.canOpenURL(phoneURL as URL) {
            UIApplication.shared.openURL(phoneURL as URL)
            return true
        }
        return false
    }
    
    
    
    
}
