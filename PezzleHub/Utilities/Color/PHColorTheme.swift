//
//  PHColorTheme.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHColorTheme {
    
    /// View Color
    var navigationBarMainBackgroundColor: UIColor { get }
    var navigationBarMainTintColor: UIColor { get }
    
    var defaultBackgroundColor: UIColor { get }
    var feedBackgroundColor: UIColor { get }
    var hubBackgroundColor: UIColor { get }
    
    var credentialBorderColor: UIColor { get }
    
    /// Tab View Color
    var tabSelectedTextColor: UIColor { get }
    var tabUnselectedTextColor: UIColor { get }
    var tabSelectedBackgroundColor: UIColor { get }
    var tabUnselectedBackgroundColor: UIColor { get }
    var tabSeparatorColor: UIColor { get }
    var tabBackgroundColor: UIColor { get }
    
    /// Text Color
    var extremelyDarkTextColor: UIColor { get }
    var extremelyLightTextColor: UIColor { get }
    
    /// UI Color
    var progressColor: UIColor { get }
}
