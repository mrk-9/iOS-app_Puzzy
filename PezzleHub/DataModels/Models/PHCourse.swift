//
//  Course.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper
import GVUserDefaults

enum PHChapterStatus {
    case delivered
    case next
    case notDelivered
}

class PHCourse: PHData {
    
    var title: String!
    var description: String!
    var imagePath: String!
    var rating: Float!
    var price: Int!
    var canGetNextChapter: Bool!
    var chaptersCount: Int!
    var isPublished: Bool!

    var lastCompletedChapter: String?
    var lastReceivedChapter: String?
    var ratingByUser: Int?

    var hashtags: [PHTag]!
    var previewImages: [String]!

    var owner: PHOwner!
    var category: PHCourseCategory!

    var deliveryInfo: [PHCourseDeliveryInfo]!

    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.title              <- map["title"]
        self.description        <- map["description"]
        self.imagePath          <- map["icon"]
        self.category           <- map["category"]["title"]
        self.rating             <- (map["rating"], PHFloatTransform<Float>())
        self.price              <- map["price"]
        self.canGetNextChapter  <- map["user_can_get_next_chapter_now"]
        self.chaptersCount      <- map["chapters_count"]
        self.isPublished        <- map["is_published"]

        self.lastCompletedChapter	<- map["last_completed_chapter"]
        self.lastReceivedChapter	<- map["last_received_chapter"]
        self.ratingByUser       <- (map["rating_by_user"])

        self.hashtags           <- (map["tags"], PHToManyRelationTransform<PHTag>())
        self.previewImages      <- map["preview_images"]

        self.owner              <- (map["owner"], PHToOneRelationTransform<PHOwner>())
        self.category           <- (map["category"], PHToOneRelationTransform<PHCourseCategory>())
        
        self.deliveryInfo       <- (map["delivery"], PHToManyRelationTransform<PHCourseDeliveryInfo>())
        
        if map["course_id"].currentValue != nil {
            self.id <- map["course_id"]
        }
    }
    
    // MARK: - 
    var isSubscribed: Bool {
        
        guard let currentUser = PHUser.currentUser else {
            
            PHUser.reloadCurrentUser()
            return false
        }
        
        return currentUser.subscribedCourseIDs.contains(self.id)
    }
    
    // MARK: - Delivery Date
    var nextDeliveryDate: Date? {
        
        var nextDate: Date? = nil
        
        for info in self.deliveryInfo {
            if let date = info.deliveryDate {
                
                if nextDate == nil {
                    nextDate = date as Date
                    continue
                }
                
                if date.compare(nextDate!) == .orderedAscending {
                    nextDate = date as Date
                }
            }
        }
        return nextDate
    }
    
    var lastCompletedChapterNumber: Int {
        
        guard let lastCompletedChapter = self.lastCompletedChapter else {
            return 0
        }
        guard let intValue = Int(lastCompletedChapter) else {
            return 0
        }
        return intValue
    }

    var lastReceivedChapterNumber: Int {
        
        guard let lastReceivedChapter = self.lastReceivedChapter else {
            return 0
        }
        guard let intValue = Int(lastReceivedChapter) else {
            return 0
        }
        return intValue
    }

    var deliveryDateDescriptionString: String? {
        
        guard self.deliveryInfo.count > 0 else {
            return nil
        }
        
        let dates = self.deliveryInfo.map { $0.descriptionString }
        let separator = ", "
        
        return "毎週 "+String(dates.joined(separator: separator))+" 配信"
    }
    
    func scheduleNextDeliveryNotification() {
        
        guard GVUserDefaults.standard().notificationEnabled else {
            return
        }
        guard self.lastCompletedChapterNumber >= self.lastReceivedChapterNumber else {
            return  // If there's a chapter already delivered, return.
        }
        guard self.lastReceivedChapterNumber < self.chaptersCount else {
            return
        }
        guard let nextDeliveryDate = self.nextDeliveryDate else {
            return
        }
        
        let application = UIApplication.shared
        
        if let localNotifications = application.scheduledLocalNotifications {
            for notification in localNotifications {
                if let userInfo = notification.userInfo {
                    if userInfo[PHNotificationType.notificationTypeKey] as! String != PHNotificationType.NextChapterDelivery.rawValue {
                        continue
                    }
                    
                    if let courseID = userInfo["course_id"] as? Int {
                        if courseID == self.id {
                            
                            application.cancelLocalNotification(notification)
                        }
                        
                    } else {

                        application.cancelLocalNotification(notification)
                    }
                }
            }
        }
        
        let courseInfo: [String: AnyObject] = self.toJSON() as [String : AnyObject]
        let nextDeliveryDateString = nextDeliveryDate.toString()
        
        GVUserDefaults.standard().setChapterDeliveryDate(courseInfo, nextDeliveryDateString: nextDeliveryDateString, forCourse: self.id)
        
        let notification = UILocalNotification()
        notification.fireDate = nextDeliveryDate
        if #available(iOS 8.2, *) {
            notification.alertTitle = "新しいチャプターが届きました！"
        } else {
        }
        notification.alertBody = self.title
        
        let courseJSON = self.toJSON()
        
        notification.userInfo = [
            PHNotificationType.notificationTypeKey: PHNotificationType.NextChapterDelivery.rawValue,
            "course_id": self.id,
            "course": courseJSON,
        ]
        application.scheduleLocalNotification(notification)
    }
    
    // MARK: - PHChapterStatus
    func getChapterStatusAtIndex(_ index: Int) -> PHChapterStatus {
        
        guard self.lastReceivedChapter != nil else {
            return .delivered
        }
        
        let isDeliveredChapter = self.lastReceivedChapterNumber >= (index + 1)
        let isNextChapter = (self.lastCompletedChapterNumber + 1 == (index + 1)) && self.canGetNextChapter
        
        if isDeliveredChapter {
            
            return .delivered
            
        } else if isNextChapter {
            
            return .next
            
        } else {
            
            return .notDelivered
        }
    }
}
