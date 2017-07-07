//
//  PHData.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/27/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHData: Mappable {
    
    var id: Int!


    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id     <- map["id"]
    }
}
