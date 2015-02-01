//
//  CBDateUtils.swift
//  CBToolkit
//
//  Created by Wes Byrne on 1/5/15.
//  Copyright (c) 2015 WCBMedia. All rights reserved.
//

import Foundation



public struct CBRelativeDateStyle {
    static let TodayOnly: String = "todayOnly"
    static let SurroundingDays: String = "surroundingOnly"
    static let FutureWeek : String = "futureWeek"
    static let PastWeek : String = "pastWeek"
    static let SurroundingWeeks: String = "surroundingWeek"
}





public extension NSDate {
    
    
    /*!
    Gets the start of the day (00:00:00) for the supplied date
    :param: date Any date to use as a base
    :returns: A new NSDate representing the start of the day for the supplied date
    */
    
    class func startOfDate(date: NSDate) -> NSDate {
        var cal = NSCalendar.currentCalendar()
        var comps = cal.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: date)
        return cal.dateFromComponents(comps)!
    }
    
    
    /*!
    Gets the end of the day (24:00:00) for the supllied date.
    :param: date Any date to use as a base
    :returns: A new NSDate representing the end of the day for the suppied date.
    */
    
    class func endOfDay(date: NSDate) -> NSDate {
        var endDate = date.dateByAddingTimeInterval(60*60*24)
        var cal = NSCalendar.currentCalendar()
        var comps = cal.components(NSCalendarUnit.YearCalendarUnit | NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: date)
        return cal.dateFromComponents(comps)!
    }
    
    
    class func startOfWeek(date: NSDate) -> NSDate {
        var nextWeek = date.dateByAddingTimeInterval(60*60*24*7)
        return NSDate.endOfWeek(nextWeek)
    }
    
    
    class func endOfWeek(date: NSDate) -> NSDate {
        var cal = NSCalendar.currentCalendar()
        var comps = cal.components(NSCalendarUnit.CalendarCalendarUnit |
            NSCalendarUnit.TimeZoneCalendarUnit |
            NSCalendarUnit.YearCalendarUnit |
            NSCalendarUnit.WeekCalendarUnit |
            NSCalendarUnit.WeekdayCalendarUnit |
            NSCalendarUnit.HourCalendarUnit |
            NSCalendarUnit.MinuteCalendarUnit |
            NSCalendarUnit.SecondCalendarUnit, fromDate: date.dateByAddingTimeInterval(60*60))
        
        comps.weekday = 1
        comps.second = 0
        comps.minute = 0
        comps.hour = 0
        
        return cal.dateFromComponents(comps)!
    }
    
    
    
    /**
    Returns a date for the next whole hour. This is useful when providing a default
    :param: date Any date to calculate the next whole hour from
    :returns: Returns a new NSDate set the the next whole hour from the provided date.
    */
    
    class func dateForNextHour(date: NSDate) -> NSDate {
        
        var cal = NSCalendar.currentCalendar()
        var comps = cal.components(NSCalendarUnit.CalendarCalendarUnit |
            NSCalendarUnit.TimeZoneCalendarUnit |
            NSCalendarUnit.YearCalendarUnit |
            NSCalendarUnit.MonthCalendarUnit |
            NSCalendarUnit.WeekdayCalendarUnit |
            NSCalendarUnit.DayCalendarUnit |
            NSCalendarUnit.HourCalendarUnit |
            NSCalendarUnit.MinuteCalendarUnit |
            NSCalendarUnit.SecondCalendarUnit, fromDate: date.dateByAddingTimeInterval(60*60))
        
        comps.second = 0
        comps.minute = 0
        
        return cal.dateFromComponents(comps)!
    }
    
    
    
    
    /*!
    Get the weekday for the date. Sunday == 1, Saturday == 7
    :returns: An Int for the day of the week sunday == 1, saturday == 7
    */
    func weekday() -> Int {
        var comps = NSCalendar.currentCalendar().components(NSCalendarUnit.WeekdayCalendarUnit, fromDate: self)
        return comps.weekday
    }
    
    
    func secondsSinceMidnight() -> Int {
        var comps = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: self)
        return ((comps.hour * 60) + comps.minute) * 60
    }
    
    
    
    
    
    
    /*!
    Determines if the supplied date is on the same calendar day as the reciever. This is useful to create 'today' labels.
    :param: compareDate A date to compare the calendar of the reciever to.
    :returns: A boolean indicating if the two dates are on the same calendar day
    */
    
    
    func isSameDayAsDate(compareDate: NSDate) -> Bool {
        
        // If they are more than 24 hrs different it can't be the same day
        var timeDiff = self.timeIntervalSinceDate(compareDate)
        if timeDiff > 60*60*24 || timeDiff < -60*60*25 {
            return false
        }
        
        var cal = NSCalendar.currentCalendar()
        var currentComps = cal.components(NSCalendarUnit.DayCalendarUnit, fromDate: self)
        var compareComps = cal.components(NSCalendarUnit.DayCalendarUnit, fromDate: compareDate)
        
        return (currentComps.day == compareComps.day)
    }
    
    /*!
    Determines if the reciever is on the same calendar day for the current time
    :returns: A boolean indicating if the reciever is sometime today
    */
    
    func isToday() -> Bool {
        return self.isSameDayAsDate(NSDate())
    }
    
    /*!
    Determines if the reciever is on the same calendar day that preceded the current day (yesterday)
    :returns: A boolean indicating if the reciever is sometime yesterday
    */

    func isYesterday() -> Bool {
        var sometimeYesterday = NSDate(timeIntervalSinceNow: -60*60*24)
        return self.isSameDayAsDate(sometimeYesterday)
    }
    
    /*!
    Determines if the reciever is on the same calendar day following the current day (tomorrow)
    :returns: A boolean indicating if the reciever is someitme tomorrow
    */
    
    func isTomorrow() -> Bool {
        var sometimeTomorrow  = NSDate(timeIntervalSinceNow: 60*60*24)
        return self.isSameDayAsDate(sometimeTomorrow)
    }
    
    
    
    
    func relativeTimeFromNow(style: String) -> String {
        
        var timeSinceNow = self.timeIntervalSinceNow
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
                var minutes = Int(timeSinceNow/60)
                return "In \(minutes) minutes"
            }
            else if self.isToday() {
                var hours = Int(timeSinceNow/60/60)
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
                var minutes = Int(-timeSinceNow/60)
                return "\(minutes) minutes ago"
            }
            else if self.isToday() {
                var hours = Int(-timeSinceNow/60/60)
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
                var comps = NSCalendar.currentCalendar().components(NSCalendarUnit.WeekdayCalendarUnit, fromDate: self)
                formattedString = "\(weekdayForIndex(comps.weekday)) at \(timeString())"
            }
            else {
                formattedString = "\(dateString()) at \(timeString())"
            }
        }
        
        return formattedString
        
    }
    
    
    
    
    
    func relativeDayFromNow(style: String, includeTime: Bool) -> String {
        
        var timeSinceNow = self.timeIntervalSinceNow
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
                    var comps = NSCalendar.currentCalendar().components(NSCalendarUnit.WeekdayCalendarUnit, fromDate: self)
                    formattedString = "\(weekdayForIndex(comps.weekday))"
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
        
        
    
    private func dateString() -> String {
        var comps = NSCalendar.currentCalendar().components(NSCalendarUnit.MonthCalendarUnit | NSCalendarUnit.DayCalendarUnit, fromDate: self)
        return "\(monthStringForIndex(comps.month)) \(comps.day)"
        
    }
    
    
    private func timeString() -> String {
        var comps = NSCalendar.currentCalendar().components(NSCalendarUnit.HourCalendarUnit | NSCalendarUnit.MinuteCalendarUnit, fromDate: self)
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
        
        var minutes = comps.minute
        var minStr = "\(minutes)"
        if minutes < 12 {
            minStr = "0\(minutes)"
        }
        
        return "\(hours):\(minStr) \(amPm)"
    }
    
    
    
    private func weekdayForIndex(index: NSInteger) -> String {
        
        assert(index <= 7, "CBDateUtils Error:  Index for day of week is invalid")
        
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
            return "Error";
        }
    }
    
    
    private func  monthStringForIndex(index : NSInteger) -> String {
        
        assert(index <= 12, "CBDateUtils Error:  Index for day of week is invalid")
        
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
            return "Error";
        }
    }

    
    
    
    
    
    
    
}