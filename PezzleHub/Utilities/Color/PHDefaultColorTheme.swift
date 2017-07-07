//
//  PHDefaultColorTheme.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHDefaultColorTheme: PHColorTheme {
    
    /// View Color
    var navigationBarMainBackgroundColor: UIColor {
        return self.almostBlackColor
    }
    var navigationBarMainTintColor: UIColor {
        return self.whiteColor
    }
    
    var defaultBackgroundColor: UIColor {
        return self.lightYellowColor
    }
    var feedBackgroundColor: UIColor {
        return self.lightYellowColor
    }
    var hubBackgroundColor: UIColor {
        return self.lightYellowColor
    }
    
    var credentialBorderColor: UIColor {
        return UIColor(decimalRed: 248, green: 240, blue: 212)
    }
    
    /// Tab View Color
    var tabSelectedTextColor: UIColor {
        return UIColor.white
    }
    var tabUnselectedTextColor: UIColor {
        return self.lightGrayTextColor2
    }
    var tabSelectedBackgroundColor: UIColor {
        return self.almostBlackColor
    }
    var tabUnselectedBackgroundColor: UIColor {
        return UIColor.white
    }
    var tabSeparatorColor: UIColor {
        return self.lightBrownColor
    }
    var tabBackgroundColor: UIColor {
        return self.darkYellowColor
    }

    /// Text Color
    var extremelyDarkTextColor: UIColor {
        return self.blackColor
    }
    var extremelyLightTextColor: UIColor {
        return self.whiteColor
    }
    
    /// UI Color
    var progressColor: UIColor {
        return self.grayColor
    }

    /// Color
    var blackColor: UIColor {
        return UIColor.black
    }
    
    var almostBlackColor: UIColor {
        return UIColor(decimalRed: 51, green: 51, blue: 51)
    }
    
    var grayColor: UIColor {
        return UIColor(decimalRed: 232, green: 234, blue: 183)
    }
    
    var grayTextColor: UIColor {
        return UIColor(decimalRed: 98, green: 96, blue: 86)
    }
    
    var lightGrayTextColor: UIColor {
        return UIColor(decimalRed: 144, green: 140, blue: 120)
    }

    var lightGrayTextColor2: UIColor {
        return UIColor(decimalRed: 132, green: 132, blue: 132)
    }

    var whiteColor: UIColor {
        return UIColor.white
    }
    
    var lightGreenColor: UIColor {
        return UIColor(decimalRed: 178, green: 201, blue: 110)
    }

    var darkYellowColor: UIColor {
        return UIColor(decimalRed: 237, green: 229, blue: 190)
    }

    var lightYellowColor: UIColor {
        return UIColor(decimalRed: 255, green: 247, blue: 215)
    }
    
    var lightBrownColor: UIColor {
        return UIColor(decimalRed: 218, green: 211, blue: 176)
    }
}
