//
//  PHOwner.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/21/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHOwner: PHUser {
        
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}
