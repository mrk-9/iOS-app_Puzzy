//
//  PHPiece.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHPiece: PHData {
    
    var title: String!
    
    var shouldDisplayInHistory: Bool {
        return true
    }
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        self.title  <- map["title"]
    }
    
    // MARK: - Utility
    class func map(_ type: String, JSONDictionary: [String: AnyObject]) -> PHPiece {
        // FixMe: Should be a better way..
        // url|user-reaction|user-play|article|picture|pdf|audio|video|owner
        
        switch type {
        case "url":
            return Mapper<PHURLPiece>().map(JSONObject: JSONDictionary)!
            
        case "user-reaction":
            return Mapper<PHUserReactionPiece>().map(JSONObject: JSONDictionary)!
            
        case "user-play":
            return Mapper<PHUserPlayPiece>().map(JSONObject: JSONDictionary)!

        case "article":
            return Mapper<PHArticlePiece>().map(JSONObject: JSONDictionary)!
            
        case "picture":
            return Mapper<PHPicturePiece>().map(JSONObject: JSONDictionary)!
            
        case "document":
            return Mapper<PHPDFPiece>().map(JSONObject: JSONDictionary)!
            
        case "audio":
            return Mapper<PHAudioPiece>().map(JSONObject: JSONDictionary)!
            
        case "video":
            return Mapper<PHVideoPiece>().map(JSONObject: JSONDictionary)!

        case "epub":    // TODO: ePub is not defined in the API right now, so check the correct type.
            return Mapper<PHEPubPiece>().map(JSONObject: JSONDictionary)!

        case "owner":
            return Mapper<PHOwnerTextPiece>().map(JSONObject: JSONDictionary)!
            
        default:
            return Mapper<PHPiece>().map(JSONObject: JSONDictionary)!   // FixMe: Once API response is fixed, there should be no default statement.
        }
    }
}
