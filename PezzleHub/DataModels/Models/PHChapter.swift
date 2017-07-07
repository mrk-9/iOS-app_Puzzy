//
//  PHChapter.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import ObjectMapper

class PHChapter: PHData {
    
    var title: String!
    var number: String!
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)

        self.title  <- map["title"]
        self.number  <- map["number"]
    }
}
