//
//  PHCourseDeliveryInfo.swift
//  PezzleHub
//
//  Created by Rajinder Paul on 17/05/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHCourseDeliveryInfo: PHData {

    fileprivate var day: String!
    fileprivate var hour: Int!
    fileprivate var minute: Int!
    
    var deliveryDayNumber: Int {
    
        switch self.day {
        case "sun":
            return 1
        case "mon":
            return 2
        case "tue":
            return 3
        case "wed":
            return 4
        case "thu":
            return 5
        case "fri":
            return 6
        case "sat":
            return 7
        default:
            return 0
        }
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.day  <- map["day"]
        self.hour  <- map["time.hour"]
        self.minute  <- map["time.minute"]
    }
    
    // MARK: - 
    var deliveryDate: Date? {
        
        var matchingNextDateComponents = DateComponents()
        
        matchingNextDateComponents.weekday = self.deliveryDayNumber
        matchingNextDateComponents.hour = self.hour
        matchingNextDateComponents.minute = self.minute
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        return (calendar as NSCalendar).nextDate(after: Date(), matching:matchingNextDateComponents, options:.matchNextTime)
    }
    
    var descriptionString: String {
        
        let dayOfWeek = [
            "sun": "日曜",
            "mon": "月曜",
            "tue": "火曜",
            "wed": "水曜",
            "thu": "木曜",
            "fri": "金曜",
            "sat": "土曜",
        ][self.day]!
        
        return "\(dayOfWeek)"+String(self.hour)+"時"
    }
}
