//
//  PHComment.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/15/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHComment: PHData {

    var comment: String!
    var date: Date!
    var author: PHAuthor!

    required init?(map: Map) {
        super.init(map: map)
    }

    override func mapping(map: Map) {
        super.mapping(map: map)

        self.comment	<- map["content"]
        self.date     	<- (map["date"], CustomDateFormatTransform(formatString: "yyyy-MM-dd'T'HH:mm:ss'Z'"))
        self.author		<- (map["author"], PHToOneRelationTransform<PHAuthor>())
    }
}
