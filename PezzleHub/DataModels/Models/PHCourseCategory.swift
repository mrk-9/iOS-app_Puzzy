//
//  PHCourseCategory.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/21/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import ObjectMapper

class PHCourseCategory: PHData {
    
    var title: String!
    var colorCode: String!
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        self.title  <- map["title"]
        self.colorCode  <- map["color"]
    }
    
    // MARK: -
    var color: UIColor {
        
        // FixMe: It's temporary. API response doesn't have 
        guard let colorCode = self.colorCode else {
            return UIColor(decimalRed: 178, green: 201, blue: 110)
        }
        
        return UIColor(hexString: colorCode)
    }
    
    var lightColor: UIColor {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        self.color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let redMultipler: CGFloat = 1.3
        let multipler: CGFloat = 1.5
        
        return UIColor(red: red * redMultipler, green: green * multipler, blue: blue * multipler, alpha: alpha)  // FixMe: Once the lighten colors are prepared, load them from data
    }
}

protocol PHCourseCategoryColoredView {
    
    func setCategoryColor(_ category: PHCourseCategory)
}
