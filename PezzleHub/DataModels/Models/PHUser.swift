//
//  PHUser.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/24/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper
import Alamofire

class PHUser: PHData {

    var encryptedID: String!
    var username: String!
    var displayName: String!
    var perzzleNumber: String!
    var description: String!
    var email: String!
    var imagePath: String?
    var subscribedCourseIDs: [Int]!
    var unreadSubscribedCoursesCount: Int!
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        self.encryptedID    <- map["encrypted_id"]
        self.username       <- map["studio_unique_name"]
        self.displayName    <- map["display_name"]
        self.description    <- map["self_introduction"]
        self.email          <- map["email"]
        self.imagePath      <- map["profile_image"]
        self.subscribedCourseIDs    <- map["subscribed_courses_list"]
        self.unreadSubscribedCoursesCount   <- map["unread_subscribed_courses_number"]
        
        self.perzzleNumber = "123456"   // FixMe: Read it from API
    }
    
    // MARK: - Current User
    static var currentUser: PHUser?
    
    class func reloadCurrentUser(_ completionHandler: ((Alamofire.DataResponse<PHUser>) -> Void)? = nil) {
        
        PHAPIManager.defaultManager.requestObject(.GetMe) { (response: Alamofire.DataResponse<PHUser>) in
            
            guard let user = response.result.value else {
                return
            }
            
            self.currentUser = user
            
            completionHandler?(response)
        }
    }
    
    class func reloadCurrentUser() {
        
    }
}
