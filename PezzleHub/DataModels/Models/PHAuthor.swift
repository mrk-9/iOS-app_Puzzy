//
//  PHAuthor.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/15/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHAuthor: PHUser {

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)
    }
}
