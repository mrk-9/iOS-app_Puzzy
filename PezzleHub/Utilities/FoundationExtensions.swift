//
//  FoundationExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import NSDate_TimeAgo

func stringFromClass(_ aClass: AnyClass) -> String {
    return NSStringFromClass(aClass).components(separatedBy: ".").last! as String
}

func performAfterDelay(_ delay: TimeInterval, block: @escaping ()->()) {
    
    let time = DispatchTime.now() + Double(Int64(delay * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time, execute: block)
}

extension Bundle {
    
    class var applicationVersion: String {
        get {
            return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String!
        }
    }
    
    class var bundleVersion: String {
        get {
            return Bundle.main.infoDictionary!["CFBundleVersion"] as! String!
        }
    }
    
    class var appName: String {
        get {
            return Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String!
        }
    }
    
    class var externalServiceKeys: [String: String] {
        return Bundle.main.infoDictionary!["ExternalServiceKeys"] as! [String : String]
    }
    
    class var serviceInfo: [String: AnyObject] {
        return Bundle.main.infoDictionary!["ServiceInfo"] as! [String : AnyObject]
    }
}

extension DateFormatter {
    
    class func defaultFormatter() -> Self {
        
        let dateFormatter = self.init()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeStyle = .full
        dateFormatter.dateStyle = .full

        return dateFormatter
    }
}

extension Date {
    
    func dateForDefaultTimezone() -> Date {
        
        let timezone = TimeZone.current
        let diff = TimeInterval(timezone.secondsFromGMT())

        return Date(timeInterval: diff, since: self)
    }
    
    func dateTimeAgoUsingDefaultTimezone() -> String {
        
        return (self.dateForDefaultTimezone() as NSDate).dateTimeAgo()
    }
    
    func dateTimeAfterUsingDefaultTimezone() -> String {

        let date = self.dateForDefaultTimezone()

        let calendar = Calendar.current
        let now = Date().dateForDefaultTimezone()
        let unitFlags: NSCalendar.Unit = [.year, .month, .weekOfYear, .day, .hour, .minute, .second]
        let components = (calendar as NSCalendar).components(unitFlags, from: now, to: date, options: .matchFirst)
        
        if components.year! >= 1 {
            
            return String(components.year!)+"年後"
            
        } else if components.month! >= 1 {

            return String(components.month!)+"ヶ月後"
        
        } else if components.weekOfYear! >= 1 {
            
            return String(components.weekOfYear!)+"週間後"

        } else if components.day! >= 1 {

            return String(components.day!)+"日後"
            
        } else if components.hour! >= 1 {

            return String(components.hour!)+"時間後"
            
        } else if components.minute! >= 1 {

            return String(components.minute!)+"分後"
            
        } else {
            
            return "もうすぐ"
        }
    }
    
    func toString() -> String {
        
        return DateFormatter.defaultFormatter().string(from: self)
    }
}

extension String {
    
    var range: NSRange {
        return NSMakeRange(0, self.characters.count)
    }
    
    func toDate() -> Date? {
        
        return DateFormatter.defaultFormatter().date(from: self)
    }
}
