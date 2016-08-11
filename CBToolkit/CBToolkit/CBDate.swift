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

// A collection of helpful date function and formatters.
public extension Date  {
    
    
    /*!
    Gets the start of the day (00:00:00) for the supplied date
    
    - param: date Any date to use as a base
    - returns: A new NSDate representing the start of the day for the supplied date
    */
    public func startOfDay() -> Date {
        let cal = Calendar.current
        let comps = cal.dateComponents(Set<Calendar.Component>([.year, .month, .day]), from: self)
        return cal.date(from: comps)!
    }
    
    /*!
    Gets the end of the day (24:00:00) for the supllied date.
    
    - param: date Any date to use as a base
    - returns: A new NSDate representing the end of the day for the suppied date.
    */
    public func endOfDay() -> Date {
        let endDate = self.addingTimeInterval(60*60*24)
        return endDate.startOfDay()
    }
    
    
    /*!
    Gets the start of the day (00:00:00) for the first day of the week containg the given date (or now if nil).
    
    - param: date Any date to use as a base
    - returns: A new NSDate representing the start of the week containing the date.
    */
    public func startOfWeek() -> Date {
        let cal = Calendar.current
        var comps = cal.dateComponents(Set<Calendar.Component>([.calendar, .timeZone, .year, .month, .weekOfYear, .weekday, .hour, .minute, .second]), from: self.addingTimeInterval(60*60))
        
        comps.weekday = 1
        comps.second = 0
        comps.minute = 0
        comps.hour = 0
        return cal.date(from: comps)!
    }
    
    /*!
    Gets the end of the day (00:00:00) for the last day of the week containg the given date (or now if nil).
    
    :param: date Any date to use as a base
    :returns: A new NSDate representing the end of the week containing the date.
    */
    public func endOfWeek() -> Date! {
        let nextWeek = self.addingTimeInterval(60*60*24*7)
        return nextWeek.startOfWeek().addingTimeInterval(-1)
    }
    
    /**
    Returns a date for the next whole hour. This is useful when providing a default
     
    - parameter date: Any date to calculate the next whole hour from
    - returns: Returns a new NSDate set the the next whole hour from the provided date.
    */
    public func nextHour() -> Date! {
        let cal = Calendar.current
        var comps = cal.dateComponents(Set<Calendar.Component>([.calendar, .timeZone, .year, .month, .weekOfYear, .weekday, .hour, .minute, .second]), from: self.addingTimeInterval(60*60))
        
        comps.second = 0
        comps.minute = 0
        return cal.date(from: comps)!
    }
    
    /**
     Inititialize a new date for the given hour and minute on the current day in a given timezone
     
     - parameter hour:       The hour of the date
     - parameter minute:     The minute of the day
     - parameter inTimezone: the timezone of the date
     
     - returns: A new NSDate set with the given parameters
     */
    public static func dateWith(hour: Int, minute: Int, timezone: NSTimeZone?) -> NSDate! {
        var cal = NSCalendar.current
        cal.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        return cal.date(bySettingHour: hour, minute: minute, second: 0, of: Date(), matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward)
//        return cal.date(bySettingHour: hour, minute: minute, second: 0, ofDate: Date(), options: Calendar.MatchingPolicy.nextTime)!
    }
    
    
    /**
     dateWithHour: Inititialize a new date for the given hour and minute on the current day in a given timezone
     
     - parameter hour:       The hour of the date
     - parameter minute:     The minute of the date
     - parameter weekday:    The weekday of the date
     - parameter inTimezone: the timezone of the date
     
     - returns: A new NSDate set with the given parameters
     */
    
    public static func dateWithHour(hour: Int, minute: Int, weekday: Int, inTimezone: TimeZone? = nil) -> NSDate! {
        let tz = inTimezone ?? NSTimeZone.local
        
        var cal = NSCalendar.current
        cal.timeZone = tz as TimeZone
        
        var comps = Date.currentComps(in: tz)
        comps.hour  = hour
        comps.minute = minute
        comps.weekday = weekday
        comps.second = 0
        
        return cal.date(from: comps)!
    }
    
    
    /**
     Retrieve the current calendar components of the reciever
     
     - parameter inTimezone: The timezone to use for the compenents
     
     - returns: NSDateComponents for the date in the given timezone
     */
    public static func currentComps(in timezone: TimeZone?) -> DateComponents {
        var cal = NSCalendar.current
        cal.timeZone = timezone ?? NSTimeZone.local
        let comps = cal.dateComponents(Set<Calendar.Component>([.calendar, .timeZone, .year, .month, .weekOfYear, .weekday, .hour, .minute, .second]), from: Date())
        return comps
    }
    
    /*!
    Get the weekday for the date. Sunday == 1, Saturday == 7
    
    - returns: An Int for the day of the week sunday == 1, saturday == 7
    */
     public func weekday() -> Int {
        return Calendar.current.component(.weekday, from: self)
    }
    
    
    public func hourIn(timezone: TimeZone?) -> Int {
        var cal = Calendar.current
        cal.timeZone = timezone ?? NSTimeZone.local
        return cal.component(.hour, from: self)
    }
    
    public func minuteIn(timezone: TimeZone?) -> Int {
        var cal = Calendar.current
        cal.timeZone = timezone ?? NSTimeZone.local
        return cal.component(.minute, from: self)
    }
    
    
    public func secondsSinceMidnight() -> Int {
        let comps = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        let h = comps.hour ?? 0
        let m = comps.hour ?? 0
        let s = comps.second ?? 0
        return (((h * 60) + m) * 60) + s
    }
    
    public func absoluteSecondsFromMidnight() -> Int {
        var cal = NSCalendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let comps = cal.dateComponents(Set<Calendar.Component>([.hour, .minute, .second]), from: self)
        let h = comps.hour ?? 0
        let m = comps.hour ?? 0
        let s = comps.second ?? 0
        return (((h * 60) + m) * 60) + s
    }
    
    /**
     Check if the reciever is in the past from now.
     
     - returns: True if the date is in the past
     */
    public var isPast : Bool {
        return self.timeIntervalSinceNow <= 0
    }
    
    /**
     Check if the reciever is in the future from now.
     
     - returns: True if the date is in the future
     */
    public var isFuture : Bool {
        return self.timeIntervalSinceNow > 0
    }
    
    /*!
    Determines if the reciever is on the same calendar day as the given date.
    
    - param: compareDate A date to compare against the reciever.
    - returns: A boolean indicating if the two dates are on the same calendar day
    */
     public func isSameDay(as date: Date) -> Bool {
        // If they are more than 24 hrs different it can't be the same day
        let timeDiff = self.timeIntervalSince(date as Date)
        if timeDiff > 60*60*24 || timeDiff < -60*60*25 {
            return false
        }
        
        let cal = Calendar.current
        let d1 = cal.component(.day, from: self)
        let d2 = cal.component(.day, from: date)
        return (d1 == d2)
    }
    
    
    /**
     Determines if the reciever falls with the same week as the given date
     
     - parameter compareDate: A date to compare againts the reciever
     - returns: A boolean indicating if the two dates are on the same calendar day
     */
    public func isSameWeek(as date: Date) -> Bool {
        let cal = Calendar.current
        let comps = Set<Calendar.Component>([.weekOfYear, .year])
        let currentComps = cal.dateComponents(comps, from: self)
        let compareComps = cal.dateComponents(comps, from: date)
        return (currentComps.year == compareComps.year && currentComps.weekOfYear == compareComps.weekOfYear)
    }
    
    /**
     Determines if the reciever falls with the same month as the given date
     
     - parameter compareDate: A date to compare againts the reciever
     - returns: A boolean indicating if the two dates are on the same calendar day
     */
    public func isSameMonth(as date: Date) -> Bool {
        let cal = Calendar.current
        let comps = Set<Calendar.Component>([.month, .year])
        let c1 = cal.dateComponents(comps, from: self)
        let c2 = cal.dateComponents(comps, from: date)
        return (c1.year == c2.year && c1.weekOfYear == c2.weekOfYear)
    }
    
    /*!
    Determines if the reciever is on the same calendar day as today
    
    - returns: A boolean indicating if the reciever is sometime today
    */
    public func isToday() -> Bool {
        return self.isSameDay(as: Date())
    }
    
    /*!
    Determines if the reciever is on the same calendar day that preceded the current day (yesterday)
    
    - returns: A boolean indicating if the reciever is sometime yesterday
    */
    public var isYesterday : Bool {
        let sometimeYesterday = Date(timeIntervalSinceNow: -60*60*24)
        return self.isSameDay(as: sometimeYesterday)
    }
    
    /*!
    Determines if the reciever is on the same calendar day following the current day (tomorrow)
    
    - returns: A boolean indicating if the reciever is someitme tomorrow
    */
    public var isTomorrow : Bool {
        let sometimeTomorrow  = Date(timeIntervalSinceNow: 60*60*24)
        return self.isSameDay(as: sometimeTomorrow)
    }
    
    /*!
    Determines if the reciever is on a calendar day within the current week
    
    - returns: A boolean indicating if the reciever is sometime next week
    */
    public var isThisWeek : Bool {
        return self.isSameWeek(as: Date())
    }
    
    /*!
    Determines if the reciever is on a calendar day within next week from now
    
    - returns: A boolean indicating if the reciever is sometime next week
    */
    public var isNextWeek : Bool {
        let sometimeNextWeek  = Date(timeIntervalSinceNow: 60*60*24*7)
        return self.isSameWeek(as: sometimeNextWeek)
    }
    
    /*!
    Determines if the reciever is on a calendar day within previous week from now
    
    - returns: A boolean indicating if the reciever is sometime the previous week
    */
    
    public var isLastWeek : Bool {
        let sometimeLastWeek  = Date(timeIntervalSinceNow: -60*60*24*7)
        return self.isSameWeek(as: sometimeLastWeek)
    }
    
    
    
    public struct AggregationNames {
        public var seconds = "s"
        public var minutes = "m"
        public var hours = "h"
        public var days = "d"
        public var weeks = "w"
        public var years = "y"
        public var shouldPluralize : Bool = false
        
        static var short: AggregationNames {
            return AggregationNames()
        }
        static var long: AggregationNames {
            return AggregationNames(seconds: " second", minutes: " minute", hours: " hour", days: " day", weeks: " week", years: " year", shouldPluralize: true)
        }
        
        func label(_ string: String, forValue: Int) -> String {
            var label = string
            if shouldPluralize && forValue != 1 { label = "\(string)s" }
            return "\(forValue)\(label)"
        }
    }
    
    
    
    /**
    A short string representation of the seconds, minutes, days, weeks, and years since the date.
    
    - returns: The string representting how many *s ago the date occured.
    */
    public func aggregateTimeSinceNow(names: AggregationNames = AggregationNames.short) -> String! {
        let sinceNow = abs(self.timeIntervalSinceNow)
        
        if sinceNow < 60 {
            return names.label(names.seconds, forValue: Int(sinceNow))
        }
        else if sinceNow < 60*60 {
            return names.label(names.minutes, forValue: Int(sinceNow/60))
        }
        else if sinceNow < 60*60*24 {
            return names.label(names.hours, forValue: Int(sinceNow/60/60))
        }
        else if sinceNow < 60*60*24*14 {
            return names.label(names.days, forValue: Int(sinceNow/60/60/24))
        }
        else if sinceNow < 60*60*24*365 {
            return names.label(names.weeks, forValue: Int(sinceNow/60/60/24/7))
        }
        else {
            return names.label(names.years, forValue: Int(sinceNow/60/60/24/365))
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
        if self.isFuture {
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
            
            if style != CBRelativeDateStyle.TodayOnly && self.isTomorrow {
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
            if style != CBRelativeDateStyle.TodayOnly && self.isYesterday {
                    return "Yesterday at \(timeString())"
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
                let wkday = Calendar.current.component(.weekday, from: self)
                formattedString = "\(Date.name(ofWeekday: wkday)) at \(timeString())"
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
            if self.isTomorrow {
                formattedString = "Tomorrow"
            }
            else if self.isYesterday {
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
                    let weekday = Calendar.current.component(.weekday, from: self)
                    formattedString = "\(Date.name(ofWeekday: weekday))"
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
     
     - returns: A day/month string for the reciever (ex. January 1)
     */
    private func dateString() -> String {
        let cal = Calendar.current
        let m = cal.component(.month, from: self)
        let d = cal.component(.day, from: self)
        return "\(cal.monthSymbols[m]) \(d)"
    }
    
    /**
     A formatted string of the time include am/pm
     
     - returns: A string representing the time in 12hr format 11:25 am
     */
    public func timeString() -> String {
        let cal = Calendar.current
        let comps = cal.dateComponents(Set<Calendar.Component>([.hour, .minute]), from: self)
        var hours = comps.hour ?? 0
        let minutes = comps.minute ?? 0
        var amPm = cal.amSymbol
        
        // Convert to 12 hr
        if hours > 12 {
            hours = hours - 12
            amPm = cal.pmSymbol
        }
        else if hours == 0 {
            hours = 12
        }
        
        
        var minStr = "\(minutes)"
        if minutes < 10 {
            minStr = "0\(minutes)"
        }
        
        return "\(hours):\(minStr) \(amPm)"
    }
    
    
    
    public enum NameStyle {
        case full
        case veryShort
        case short
    }
    
    
    /**
     The text representation of the weekday index 1-7
     
     - parameter index: The numeric index of the weekday (1-7)
     - returns: A text representation of the weekday for the given index
     */
    public static func name(ofWeekday atIndex: NSInteger, style : NameStyle = .full, calendar: Calendar = .current) -> String {
        
        var symbols : [String]
        switch style {
        case .full: symbols = calendar.weekdaySymbols
        case .short: symbols = calendar.shortWeekdaySymbols
        case .veryShort: symbols = calendar.veryShortMonthSymbols
        }
        
        if symbols.count > 0 && symbols.count < atIndex {
            return symbols[atIndex]
        }
        
        
        switch (atIndex) {
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
            if atIndex > 7 {
                return "Saturday"
            }
            return "Sunday"
        }
    }
    
    /**
     The text representation of the month index (1-12)
     
     - parameter index: The numeric index of the month (1-12)
     - returns: A text representation of the month for the given index
     */
    public static func  name(ofMonth atIndex : Int, style: NameStyle = .full, calendar: Calendar = Calendar.current) -> String {
        
        var symbols : [String]
        switch style {
        case .full:
            symbols = calendar.monthSymbols
        case .short:
            symbols = calendar.shortMonthSymbols
        case .veryShort:
            symbols = calendar.veryShortMonthSymbols
        }
        
        if symbols.count > 0 && symbols.count < atIndex {
            return symbols[atIndex]
        }
        
        switch (atIndex) {
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
            if atIndex < 1 { return "January" }
            return "December"
        }
    }

    
    
    
    
    
    
    
}
