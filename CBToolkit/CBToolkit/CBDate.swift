//
//  CBDateUtils.swift
//  CBToolkit
//
//  Created by Wes Byrne on 1/5/15.
//  Copyright (c) 2015 WCBMedia. All rights reserved.
//

import Foundation


/**
 Formatting styles to use with CBDate formating functions indicating when to use relative weekday names vs a date string
 
 - TodayOnly:        Show dates within the current calendar day as today
 - SurroundingDays:  Return dates on the current, previous, or following calendar days as Today, Yesterday, and Tomorrow respectively
 - FutureWeek:       Return dates within the upcoming 7 calendar days as Today, Tomorrow or the relevant weekday
 - PastWeek:         Return dates within the preview 7 calendar days as Today, Yesterday or the relevant weekday
 - SurroundingWeeks: Return dates within the upcoming or previews 7 calendar days as Today, Tomorrow or the relevant weekday
 */
public enum CBRelativeDateStyle: Int {
    case TodayOnly
    case SurroundingDays
    case FutureWeek
    case PastWeek
    case SurroundingWeeks
}


public extension NSDate  {
    
    
    /*!
    Gets the start of the day (00:00:00) for the supplied date
    
    - param: date Any date to use as a base
    - returns: A new NSDate representing the start of the day for the supplied date
    */
    class public func startOfDay(date: NSDate? = NSDate()) -> NSDate! {
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: date!)
        return cal.dateFromComponents(comps)!
    }
    
    /*!
    Gets the end of the day (24:00:00) for the supllied date.
    
    - param: date Any date to use as a base
    - returns: A new NSDate representing the end of the day for the suppied date.
    */
    class public func endOfDay(date: NSDate? = NSDate()) -> NSDate! {
        let endDate = date!.dateByAddingTimeInterval(60*60*24)
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: endDate)
        return cal.dateFromComponents(comps)!
    }
    
    
    /*!
    Gets the start of the day (00:00:00) for the first day of the week containg the given date (or now if nil).
    
    - param: date Any date to use as a base
    - returns: A new NSDate representing the start of the week containing the date.
    */
    class public func startOfWeek(date: NSDate? = NSDate()) -> NSDate! {
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Calendar, NSCalendarUnit.TimeZone, NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Weekday, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date!.dateByAddingTimeInterval(60*60))
        
        comps.weekday = 1
        comps.second = 0
        comps.minute = 0
        comps.hour = 0
        return cal.dateFromComponents(comps)!
    }
    
    /*!
    Gets the end of the day (00:00:00) for the last day of the week containg the given date (or now if nil).
    
    :param: date Any date to use as a base
    :returns: A new NSDate representing the end of the week containing the date.
    */
    class public func endOfWeek(date: NSDate? = NSDate()) -> NSDate! {
        let nextWeek = date!.dateByAddingTimeInterval(60*60*24*7)
        return NSDate.startOfWeek(nextWeek).dateByAddingTimeInterval(-1)
    }
    
    /**
    Returns a date for the next whole hour. This is useful when providing a default
     
    - parameter date: Any date to calculate the next whole hour from
    - returns: Returns a new NSDate set the the next whole hour from the provided date.
    */
    class public func dateForNextHour(date: NSDate? = NSDate()) -> NSDate! {
        
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([NSCalendarUnit.Calendar, NSCalendarUnit.TimeZone, NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Weekday, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: date!.dateByAddingTimeInterval(60*60))
        
        comps.second = 0
        comps.minute = 0
        return cal.dateFromComponents(comps)!
    }
    
    
    /**
     Initialized a new date for the given hour and minute on the current day
     
     - parameter hour:   The hour of the date
     - parameter minute: The minute of the date
     
     - returns: A new NSDate set with the given hour and minute on today
     */
    public class func dateWithHour(hour: Int, minute: Int) -> NSDate! {
        return dateWithHour(hour, minute: minute, inTimezone: nil)
    }
    
    /**
     Inititialize a new date for the given hour and minute on the current day in a given timezone
     
     - parameter hour:       The hour of the date
     - parameter minute:     The minute of the day
     - parameter inTimezone: the timezone of the date
     
     - returns: A new NSDate set with the given parameters
     */
    public class func dateWithHour(hour: Int, minute: Int, inTimezone: NSTimeZone?) -> NSDate! {
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        return cal.dateBySettingHour(hour, minute: minute, second: 0, ofDate: NSDate(), options: NSCalendarOptions.MatchFirst)!
    }
    
    
    /**
     dateWithHour: Inititialize a new date for the given hour and minute on the current day in a given timezone
     
     - parameter hour:       The hour of the date
     - parameter minute:     The minute of the date
     - parameter weekday:    The weekday of the date
     - parameter inTimezone: the timezone of the date
     
     - returns: A new NSDate set with the given parameters
     */
    
    public class func dateWithHour(hour: Int, minute: Int, weekday: Int, inTimezone: NSTimeZone) -> NSDate! {
        let tz = inTimezone ?? NSTimeZone.localTimeZone()
        
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = tz
        
        let comps = NSDate.currentComps(tz)
        comps.hour  = hour
        comps.minute = minute
        comps.weekday = weekday
        comps.second = 0
        
        return cal.dateFromComponents(comps)!
    }
    
    
    /**
     Retrieve the current calendar components of the reciever
     
     - parameter inTimezone: The timezone to use for the compenents
     
     - returns: NSDateComponents for the date in the given timezone
     */
    public class func currentComps(inTimezone: NSTimeZone?) -> NSDateComponents! {
        
        let tz = inTimezone ?? NSTimeZone.localTimeZone()
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = tz
        let comps = cal.components([NSCalendarUnit.Calendar, NSCalendarUnit.TimeZone, NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.WeekOfYear, NSCalendarUnit.Weekday, NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second], fromDate: NSDate())
        return comps
    }
    
    /*!
    Get the weekday for the date. Sunday == 1, Saturday == 7
    
    - returns: An Int for the day of the week sunday == 1, saturday == 7
    */
     public func weekday() -> Int {
        let comps = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: self)
        return comps.weekday
    }
    
    
    public func hourInTimeZone(inTimezone: NSTimeZone?) -> Int {
        let tz: NSTimeZone = inTimezone ?? NSTimeZone.localTimeZone()
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = tz
        let comps = cal.components(NSCalendarUnit.Hour, fromDate: self)
        return comps.hour
    }
    
    public func minuteInTimeZone(inTimezone: NSTimeZone?) -> Int {
        let tz: NSTimeZone = inTimezone ?? NSTimeZone.localTimeZone()
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = tz
        let comps = cal.components(NSCalendarUnit.Minute, fromDate: self)
        return comps.minute
    }
    
    
     public func secondsSinceMidnight() -> Int {
        let comps = NSCalendar.currentCalendar().components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: self)
        return ((comps.hour * 60) + comps.minute) * 60
    }
    
    public func absoluteSecondsFromMidnight() -> Int {
        let cal = NSCalendar.currentCalendar()
        cal.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        let comps = cal.components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: self)
        return ((comps.hour * 60) + comps.minute) * 60
        
    }
    
    
    
    
    /*!
    Determines if the reciever is on the same calendar day as the given date.
    
    - param: compareDate A date to compare against the reciever.
    - returns: A boolean indicating if the two dates are on the same calendar day
    */
     public func isSameDayAsDate(compareDate: NSDate) -> Bool {
        // If they are more than 24 hrs different it can't be the same day
        let timeDiff = self.timeIntervalSinceDate(compareDate)
        if timeDiff > 60*60*24 || timeDiff < -60*60*25 {
            return false
        }
        
        let cal = NSCalendar.currentCalendar()
        let currentComps = cal.components(NSCalendarUnit.Day, fromDate: self)
        let compareComps = cal.components(NSCalendarUnit.Day, fromDate: compareDate)
        
        return (currentComps.day == compareComps.day)
    }
    
    
    /**
     Determines if the reciever falls with the same week as the given date
     
     - parameter compareDate: A date to compare againts the reciever
     - returns: A boolean indicating if the two dates are on the same calendar day
     */
    public func isSameWeekAsDate(compareDate: NSDate) -> Bool {
        let cal = NSCalendar.currentCalendar()
        let currentComps = cal.components([NSCalendarUnit.WeekOfYear, NSCalendarUnit.Year], fromDate: self)
        let compareComps = cal.components([NSCalendarUnit.WeekOfYear, .Year], fromDate: compareDate)
        return (currentComps.year == compareComps.year && currentComps.weekOfYear == compareComps.weekOfYear)
    }
    
    /**
     Determines if the reciever falls with the same month as the given date
     
     - parameter compareDate: A date to compare againts the reciever
     - returns: A boolean indicating if the two dates are on the same calendar day
     */
    public func isSameMonthAsDate(compareDate: NSDate) -> Bool {
        let cal = NSCalendar.currentCalendar()
        let currentComps = cal.components([NSCalendarUnit.Month, NSCalendarUnit.Year], fromDate: self)
        let compareComps = cal.components([NSCalendarUnit.Month, .Year], fromDate: compareDate)
        return (currentComps.year == compareComps.year && currentComps.weekOfYear == compareComps.weekOfYear)
    }
    
    /*!
    Determines if the reciever is on the same calendar day as today
    
    - returns: A boolean indicating if the reciever is sometime today
    */
    public func isToday() -> Bool {
        return self.isSameDayAsDate(NSDate())
    }
    
    /*!
    Determines if the reciever is on the same calendar day that preceded the current day (yesterday)
    
    - returns: A boolean indicating if the reciever is sometime yesterday
    */
     public func isYesterday() -> Bool {
        let sometimeYesterday = NSDate(timeIntervalSinceNow: -60*60*24)
        return self.isSameDayAsDate(sometimeYesterday)
    }
    
    /*!
    Determines if the reciever is on the same calendar day following the current day (tomorrow)
    
    - returns: A boolean indicating if the reciever is someitme tomorrow
    */
     public func isTomorrow() -> Bool {
        let sometimeTomorrow  = NSDate(timeIntervalSinceNow: 60*60*24)
        return self.isSameDayAsDate(sometimeTomorrow)
    }
    
    /*!
    Determines if the reciever is on a calendar day within the current week
    
    - returns: A boolean indicating if the reciever is sometime next week
    */
    public func isThisWeek() -> Bool {
        return self.isSameWeekAsDate(NSDate())
    }
    
    /*!
    Determines if the reciever is on a calendar day within next week from now
    
    - returns: A boolean indicating if the reciever is sometime next week
    */
    public func isNextWeek() -> Bool {
        let sometimeNextWeek  = NSDate(timeIntervalSinceNow: 60*60*24*7)
        return self.isSameWeekAsDate(sometimeNextWeek)
    }
    
    /*!
    Determines if the reciever is on a calendar day within previous week from now
    
    - returns: A boolean indicating if the reciever is sometime the previous week
    */
    
    public func isLastWeek() -> Bool {
        let sometimeLastWeek  = NSDate(timeIntervalSinceNow: -60*60*24*7)
        return self.isSameWeekAsDate(sometimeLastWeek)
    }
    
    
    
    /**
    A short string representation of the seconds, minutes, days, weeks, and years since the date.
    
    - returns: The string representting how many *s ago the date occured.
    */
    public func aggregateTimeSinceNow() -> String! {
        let sinceNow = abs(self.timeIntervalSinceNow)
        
        if sinceNow < 60 {
            return "\(Int(sinceNow))s"
        }
        else if sinceNow < 60*60 {
            return "\(Int(sinceNow/60))m"
        }
        else if sinceNow < 60*60*24 {
            return "\(Int(sinceNow/60/60))h"
        }
        else if sinceNow < 60*60*24*30 {
            return "\(Int(sinceNow/60/60/24))d"
        }
        else if sinceNow < 60*60*24*365 {
            return "\(Int(sinceNow/60/60/24/7))w"
        }
        else {
            return "\(Int(sinceNow/60/60/24/365))y"
        }
    }
    
    
    /*!
    Creates a string describing the time the date occured relative to now. ex. 'in 1 hour' or '10 minutes ago'.
    
    - param: style       A string value of one of the CBRelativeDataStyle values
    - returns: A string representation of the date relative to now.
    */
    
     public func relativeTimeFromNow(style: CBRelativeDateStyle) -> String {
        
        let timeSinceNow = self.timeIntervalSinceNow
        var formattedString: String = ""
        
        // Hasn't happened yet
        if timeSinceNow > 0 {
            if timeSinceNow < 60 {
                return "Now"
            }
            else if timeSinceNow < 60*5 {
                return "Moments from now"
            }
            else if timeSinceNow < 60*60 {
                let minutes = Int(timeSinceNow/60)
                return "In \(minutes) minutes"
            }
            else if self.isToday() {
                let hours = Int(timeSinceNow/60/60)
                if hours < 6 {
                    var hourStr = "In \(hours) hour"
                    if hours != 1 {
                        hourStr = "\(hourStr)s"
                    }
                    return hourStr
                }
                return "Today at \(timeString())"
            }
            
            if style != CBRelativeDateStyle.TodayOnly && self.isTomorrow() {
                    "Tomorrow at \(timeString())"
            }
        }
            
        // Already Past
        else {
            if timeSinceNow > -60 {
                return "Now"
            }
            else if timeSinceNow > -60*5 {
                return "Moments ago"
            }
            else if timeSinceNow > -60*60 {
                let minutes = Int(-timeSinceNow/60)
                return "\(minutes) minutes ago"
            }
            else if self.isToday() {
                let hours = Int(-timeSinceNow/60/60)
                formattedString =  "\(hours) hour"
                if hours != 1 {
                    formattedString = "\(formattedString)s"
                }
                formattedString = "\(formattedString) ago"
            }
            if style != CBRelativeDateStyle.TodayOnly && self.isYesterday() {
                    "Yesterday at \(timeString())"
            }
        }
        
        if formattedString.isEmpty {
            var showWeekday = false
            // Upcoming weeke
            if (style == CBRelativeDateStyle.FutureWeek || style == CBRelativeDateStyle.SurroundingWeeks) && timeSinceNow > 0 && timeSinceNow < 60*60*24*7 {
                showWeekday = true
            }
            else if (style == CBRelativeDateStyle.PastWeek || style == CBRelativeDateStyle.SurroundingWeeks) && timeSinceNow < 0 && timeSinceNow > -60*60*24*7 {
                showWeekday = true
            }
            
            if showWeekday {
                let comps = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: self)
                formattedString = "\(NSDate.weekdayForIndex(comps.weekday)) at \(timeString())"
            }
            else {
                formattedString = "\(dateString()) at \(timeString())"
            }
        }
        
        return formattedString
    }
    
    
    
    /*!
    Creates a string describing the when the data occured relative to now. ex. Tomorrow at 2:30pm. If the date is more than a week away the date will be used
    
    - param: style       A string value of one of the CBRelativeDataStyle values
    - param: includeTime Option to include the time in the string or not.
    
    - returns: A string representation of the date relative to now.
    */
     public func relativeDayFromNow(style: CBRelativeDateStyle, includeTime: Bool) -> String {
        
        let timeSinceNow = self.timeIntervalSinceNow
        var formattedString: String = ""
        
        if self.isToday() {
            formattedString = "Today"
        }
        else if style != CBRelativeDateStyle.TodayOnly {
            if self.isTomorrow() {
                formattedString = "Tomorrow"
            }
            else if self.isYesterday() {
                formattedString = "Yesterday"
            }
            else {
                var showWeekday = false
                // Upcoming weeke
                if (style == CBRelativeDateStyle.FutureWeek || style == CBRelativeDateStyle.SurroundingWeeks) && timeSinceNow > 0 && timeSinceNow < 60*60*24*7 {
                    showWeekday = true
                }
                else if (style == CBRelativeDateStyle.PastWeek || style == CBRelativeDateStyle.SurroundingWeeks) && timeSinceNow < 0 && timeSinceNow > -60*60*24*7 {
                    showWeekday = true
                }
                
                if showWeekday {
                    let comps = NSCalendar.currentCalendar().components(NSCalendarUnit.Weekday, fromDate: self)
                    formattedString = "\(NSDate.weekdayForIndex(comps.weekday))"
                }
            }
        }
        
        if formattedString.isEmpty {
            formattedString = self.dateString()
        }
        
        if includeTime {
            formattedString = "\(formattedString) at \(self.timeString())"
        }
        
        return formattedString
    }
        
        
    /**
     A day/month string representation of the reciever
     
     - returns: A day/month string for the reciever
     */
    private func dateString() -> String {
        let comps = NSCalendar.currentCalendar().components([NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: self)
        return "\(NSDate.monthStringForIndex(comps.month)) \(comps.day)"
        
    }
    
    /**
     A formatted string of the time include am/pm
     
     - returns: A string representing the time in 12hr format 11:25 am
     */
    public func timeString() -> String {
        let comps = NSCalendar.currentCalendar().components([NSCalendarUnit.Hour, NSCalendarUnit.Minute], fromDate: self)
        var hours = comps.hour
        var amPm = "am"
        
        // Convert to 12 hr
        if hours > 12 {
            hours = hours - 12
            amPm = "pm"
        }
        else if hours == 0 {
            hours = 12
        }
        
        let minutes = comps.minute
        var minStr = "\(minutes)"
        if minutes < 10 {
            minStr = "0\(minutes)"
        }
        
        return "\(hours):\(minStr) \(amPm)"
    }
    
    
    /**
     The text representation of the weekday index 1-7
     
     - parameter index: The numeric index of the weekday (1-7)
     - returns: A text representation of the weekday for the given index
     */
    public class func weekdayForIndex(index: NSInteger) -> String {
        
        switch (index) {
        case 1:
            return "Sunday";
        case 2:
            return "Monday";
        case 3:
            return "Tuesday";
        case 4:
            return "Wednesday";
        case 5:
            return "Thursday";
        case 6:
            return "Friday";
        case 7:
            return "Saturday";
            
        default:
            print("Weekday for index invalid but returning closest day")
            if index > 7 {
                return "Saturday"
            }
            else {
                return "Sunday"
            }
        }
    }
    
    /**
     The abbreviated text representation of the weekday index 1-7
     
     - parameter index: The numeric index of the weekday (1-7)
     - returns: An abbreviated text representation of the weekday for the given index
     */
    public class func weekdayShortforIndex(index: NSInteger) -> String {
        
        switch (index) {
        case 1:
            return "Sun";
        case 2:
            return "Mon";
        case 3:
            return "Tue";
        case 4:
            return "Wed";
        case 5:
            return "Thur";
        case 6:
            return "Fri";
        case 7:
            return "Sat";
            
        default:
            if index > 7 {
                return "Sat"
            }
            else {
                return "Sun"
            }
        }
    }

    /**
     The text representation of the month index (1-12)
     
     - parameter index: The numeric index of the month (1-12)
     - returns: A text representation of the month for the given index
     */
    public class func  monthStringForIndex(index : NSInteger) -> String {
        
        switch (index) {
        case 1:
            return "January";
        case 2:
            return "February";
        case 3:
            return "March";
        case 4:
            return "April";
        case 5:
            return "May";
        case 6:
            return "June";
        case 7:
            return "July";
        case 8:
            return "August";
        case 9:
            return "September";
        case 10:
            return "October";
        case 11:
            return "November";
        case 12:
            return "December";
            
        default:
            if index < 1 {
                return "January"
            }
            return "December"
        }
    }

    
    
    
    
    
    
    
}