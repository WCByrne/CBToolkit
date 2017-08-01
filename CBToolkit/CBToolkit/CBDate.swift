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
    case todayOnly
    case surroundingDays
    case futureWeek
    case pastWeek
    case surroundingWeeks
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
        let comps = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: self)
        return cal.date(from: comps)!
    }
    
    /*!
     Gets the end of the day (24:00:00) for the supllied date.
     
     - param: date Any date to use as a base
     - returns: A new NSDate representing the end of the day for the suppied date.
     */
    public func endOfDay() -> Date {
        let endDate = self.addingTimeInterval(60*60*24)
        let cal = Calendar.current
        let comps = (cal as NSCalendar).components([NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day], from: endDate)
        return cal.date(from: comps)!
    }
    
    
    /*!
     Gets the start of the day (00:00:00) for the first day of the week containg the given date (or now if nil).
     
     - param: date Any date to use as a base
     - returns: A new NSDate representing the start of the week containing the date.
     */
    public func startOfWeek() -> Date {
        let cal = Calendar.current
        var comps = (cal as NSCalendar).components([NSCalendar.Unit.calendar, NSCalendar.Unit.timeZone, NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second], from: self.addingTimeInterval(60*60))
        
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
    public func endOfWeek() -> Date {
        let nextWeek = self.addingTimeInterval(60*60*24*7)
        return nextWeek.startOfWeek().addingTimeInterval(-1)
    }
    
    /**
     Returns a date for the next whole hour. This is useful when providing a default
     
     - parameter date: Any date to calculate the next whole hour from
     - returns: Returns a new NSDate set the the next whole hour from the provided date.
     */
    public var nextHour : Date {
        
        let cal = Calendar.current
        var comps = (cal as NSCalendar).components([NSCalendar.Unit.calendar, NSCalendar.Unit.timeZone, NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second], from: self.addingTimeInterval(60*60))
        
        comps.second = 0
        comps.minute = 0
        return cal.date(from: comps)!
    }
    
    
    /**
     Initialized a new date for the given hour and minute on the current day
     
     - parameter hour:   The hour of the date
     - parameter minute: The minute of the date
     
     - returns: A new NSDate set with the given hour and minute on today
     */
    public static func dateWithHour(_ hour: Int, minute: Int) -> Date {
        return dateWithHour(hour, minute: minute, inTimezone: nil)
    }
    
    /**
     Inititialize a new date for the given hour and minute on the current day in a given timezone
     
     - parameter hour:       The hour of the date
     - parameter minute:     The minute of the day
     - parameter inTimezone: the timezone of the date
     
     - returns: A new NSDate set with the given parameters
     */
    public static func dateWithHour(_ hour: Int, minute: Int, inTimezone: TimeZone?) -> Date {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        return (cal as NSCalendar).date(bySettingHour: hour, minute: minute, second: 0, of: Date(), options: NSCalendar.Options.matchFirst)!
    }
    
    
    /**
     dateWithHour: Inititialize a new date for the given hour and minute on the current day in a given timezone
     
     - parameter hour:       The hour of the date
     - parameter minute:     The minute of the date
     - parameter weekday:    The weekday of the date
     - parameter inTimezone: the timezone of the date
     
     - returns: A new NSDate set with the given parameters
     */
    
    public static func dateWithHour(_ hour: Int, minute: Int, weekday: Int, inTimezone: TimeZone) -> Date {
        let tz = inTimezone
        
        var cal = Calendar.current
        cal.timeZone = tz
        
        var comps = Date.currentComps(tz)
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
    public static func currentComps(_ inTimezone: TimeZone?) -> DateComponents {
        
        let tz = inTimezone ?? TimeZone.autoupdatingCurrent
        var cal = Calendar.current
        cal.timeZone = tz
        let comps = (cal as NSCalendar).components([NSCalendar.Unit.calendar, NSCalendar.Unit.timeZone, NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.weekday, NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second], from: Date())
        return comps
    }
    
    /*!
     Get the weekday for the date. Sunday == 1, Saturday == 7
     
     - returns: An Int for the day of the week sunday == 1, saturday == 7
     */
    public func weekday(in timezone: TimeZone = TimeZone.autoupdatingCurrent) -> Int {
        var cal = Calendar.current
        cal.timeZone = timezone
        return cal.component(.weekday, from: self)
    }
    
    
    public func hour(in timezone: TimeZone = TimeZone.autoupdatingCurrent) -> Int {
        var cal = Calendar.current
        cal.timeZone = timezone
        return cal.component(.hour, from: self)
    }
    
    public func minute(in timezone: TimeZone = TimeZone.autoupdatingCurrent) -> Int {
        var cal = Calendar.current
        cal.timeZone = timezone
        return cal.component(.minute, from: self)
    }
    
    
    public func secondsSinceMidnight() -> Int {
        let comps = (Calendar.current as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: self)
        return ((comps.hour! * 60) + comps.minute!) * 60
    }
    
    public func absoluteSecondsFromMidnight() -> Int {
        var cal = Calendar.current
        cal.timeZone = TimeZone(secondsFromGMT: 0)!
        let comps = (cal as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute], from: self)
        return ((comps.hour! * 60) + comps.minute!) * 60
        
    }
    
    /**
     Check if the reciever is in the past from now.
     
     - returns: True if the date is in the past
     */
    public var isPast : Bool {
        return self.timeIntervalSinceNow <= 0
    }
    
    public func isBefore(_ date: Date) -> Bool {
        return self.compare(date) == .orderedAscending
    }
    public func isAfter(_ date: Date) -> Bool {
        return self.compare(date) == .orderedDescending
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
    public func isSameDayAsDate(_ compareDate: Date) -> Bool {
        // If they are more than 24 hrs different it can't be the same day
        let timeDiff = self.timeIntervalSince(compareDate)
        if timeDiff > 60*60*24 || timeDiff < -60*60*25 {
            return false
        }
        
        let cal = Calendar.current
        let currentComps = (cal as NSCalendar).components(NSCalendar.Unit.day, from: self)
        let compareComps = (cal as NSCalendar).components(NSCalendar.Unit.day, from: compareDate)
        
        return (currentComps.day == compareComps.day)
    }
    
    
    
    
    /**
     Determines if the reciever falls with the same week as the given date
     
     - parameter compareDate: A date to compare againts the reciever
     - returns: A boolean indicating if the two dates are on the same calendar day
     */
    public func isSameWeekAsDate(_ compareDate: Date) -> Bool {
        let cal = Calendar.current
        let currentComps = (cal as NSCalendar).components([NSCalendar.Unit.weekOfYear, NSCalendar.Unit.year], from: self)
        let compareComps = (cal as NSCalendar).components([NSCalendar.Unit.weekOfYear, .year], from: compareDate)
        return (currentComps.year == compareComps.year && currentComps.weekOfYear == compareComps.weekOfYear)
    }
    
    public func isSameYearAsDate(_ compareDate: Date) -> Bool {
        let cal = Calendar.current
        let currentComps = (cal as NSCalendar).components([.year], from: self)
        let compareComps = (cal as NSCalendar).components([.year], from: compareDate)
        return currentComps.year == compareComps.year
    }
    
    /**
     Determines if the reciever falls with the same month as the given date
     
     - parameter compareDate: A date to compare againts the reciever
     - returns: A boolean indicating if the two dates are on the same calendar day
     */
    public func isSameMonthAsDate(_ compareDate: Date) -> Bool {
        let cal = Calendar.current
        let currentComps = (cal as NSCalendar).components([NSCalendar.Unit.month, NSCalendar.Unit.year], from: self)
        let compareComps = (cal as NSCalendar).components([NSCalendar.Unit.month, .year], from: compareDate)
        return (currentComps.year == compareComps.year && currentComps.weekOfYear == compareComps.weekOfYear)
    }
    
    /*!
     Determines if the reciever is on the same calendar day as today
     
     - returns: A boolean indicating if the reciever is sometime today
     */
    public func isToday() -> Bool {
        return self.isSameDayAsDate(Date())
    }
    
    /*!
     Determines if the reciever is on the same calendar day that preceded the current day (yesterday)
     
     - returns: A boolean indicating if the reciever is sometime yesterday
     */
    public func isYesterday() -> Bool {
        let sometimeYesterday = Date(timeIntervalSinceNow: -60*60*24)
        return self.isSameDayAsDate(sometimeYesterday)
    }
    
    /*!
     Determines if the reciever is on the same calendar day following the current day (tomorrow)
     
     - returns: A boolean indicating if the reciever is someitme tomorrow
     */
    public func isTomorrow() -> Bool {
        let sometimeTomorrow  = Date(timeIntervalSinceNow: 60*60*24)
        return self.isSameDayAsDate(sometimeTomorrow)
    }
    
    /*!
     Determines if the reciever is on a calendar day within the current week
     
     - returns: A boolean indicating if the reciever is sometime next week
     */
    public func isThisWeek() -> Bool {
        return self.isSameWeekAsDate(Date())
    }
    
    /*!
     Determines if the reciever is on a calendar day within next week from now
     
     - returns: A boolean indicating if the reciever is sometime next week
     */
    public func isNextWeek() -> Bool {
        let sometimeNextWeek  = Date(timeIntervalSinceNow: 60*60*24*7)
        return self.isSameWeekAsDate(sometimeNextWeek)
    }
    
    /*!
     Determines if the reciever is on a calendar day within previous week from now
     
     - returns: A boolean indicating if the reciever is sometime the previous week
     */
    
    public func isLastWeek() -> Bool {
        let sometimeLastWeek  = Date(timeIntervalSinceNow: -60*60*24*7)
        return self.isSameWeekAsDate(sometimeLastWeek)
    }
    
    
    
    /**
     A short string representation of the seconds, minutes, days, weeks, and years since the date.
     
     - returns: The string representting how many *s ago the date occured.
     */
    
    public struct AggregationNames {
        public var seconds = "s"
        public var minutes = "m"
        public var hours = "h"
        public var days = "d"
        public var weeks = "w"
        public var years = "y"
        public var shouldPluralize : Bool = false
        
        public static var short: AggregationNames {
            return AggregationNames()
        }
        public static var long: AggregationNames {
            return AggregationNames(seconds: " second", minutes: " minute", hours: " hour", days: " day", weeks: " week", years: " year", shouldPluralize: true)
        }
        
        func label(_ string: String, forValue: Int) -> String {
            var label = string
            if shouldPluralize && forValue != 1 { label = "\(string)s" }
            return "\(forValue)\(label)"
        }
    }
    
    public func aggregateTimeSinceNow(_ names: AggregationNames = AggregationNames.short) -> String {
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
    
    public func relativeTimeFromNow(_ style: CBRelativeDateStyle) -> String {
        
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
            
            if style != CBRelativeDateStyle.todayOnly && self.isTomorrow() {
                return "Tomorrow at \(timeString())"
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
            if style != CBRelativeDateStyle.todayOnly && self.isYesterday() {
                return "Yesterday at \(timeString())"
            }
        }
        
        if formattedString.isEmpty {
            var showWeekday = false
            // Upcoming weeke
            if (style == CBRelativeDateStyle.futureWeek || style == CBRelativeDateStyle.surroundingWeeks) && timeSinceNow > 0 && timeSinceNow < 60*60*24*7 {
                showWeekday = true
            }
            else if (style == CBRelativeDateStyle.pastWeek || style == CBRelativeDateStyle.surroundingWeeks) && timeSinceNow < 0 && timeSinceNow > -60*60*24*7 {
                showWeekday = true
            }
            
            if showWeekday {
                let comps = (Calendar.current as NSCalendar).components(NSCalendar.Unit.weekday, from: self)
                formattedString = "\(Date.weekdayForIndex(comps.weekday!)) at \(timeString())"
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
    public func relativeDayFromNow(_ style: CBRelativeDateStyle, includeTime: Bool, excludeTimePastYear: Bool = false) -> String {
        
        let timeSinceNow = self.timeIntervalSinceNow
        var formattedString: String = ""
        
        if self.isToday() {
            formattedString = "Today"
        }
        else if style != CBRelativeDateStyle.todayOnly {
            if self.isTomorrow() {
                formattedString = "Tomorrow"
            }
            else if self.isYesterday() {
                formattedString = "Yesterday"
            }
            else {
                var showWeekday = false
                // Upcoming weeke
                if (style == CBRelativeDateStyle.futureWeek || style == CBRelativeDateStyle.surroundingWeeks) && timeSinceNow > 0 && timeSinceNow < 60*60*24*7 {
                    showWeekday = true
                }
                else if (style == CBRelativeDateStyle.pastWeek || style == CBRelativeDateStyle.surroundingWeeks) && timeSinceNow < 0 && timeSinceNow > -60*60*24*7 {
                    showWeekday = true
                }
                
                if showWeekday {
                    let comps = (Calendar.current as NSCalendar).components(NSCalendar.Unit.weekday, from: self)
                    formattedString = "\(Date.weekdayForIndex(comps.weekday!))"
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
    func dateString() -> String {
        let comps = Calendar.current.dateComponents(Set([Calendar.Component.month, Calendar.Component.day]), from: self)
        return "\(Date.monthStringForIndex(comps.month!)) \(comps.day!)"
    }
    
    /**
     A formatted string of the time include am/pm
     
     - returns: A string representing the time in 12hr format 11:25 am
     */
    public func timeString() -> String {
        let comps = Calendar.current.dateComponents(Set([Calendar.Component.hour, Calendar.Component.minute]), from: self)
        var hours : Int = comps.hour ?? 0
        var amPm = "am"
        
        // Convert to 12 hr
        if hours > 12 {
            hours = hours - 12
            amPm = "pm"
        }
        else if hours == 0 {
            hours = 12
        }
        
        let minutes : Int = comps.minute ?? 0
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
    public static func weekdayForIndex(_ index: NSInteger) -> String {
        
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
    public static func weekdayShortforIndex(_ index: NSInteger) -> String {
        
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
    public static func  monthStringForIndex(_ index : NSInteger) -> String {
        
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
