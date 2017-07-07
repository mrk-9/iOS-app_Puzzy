//
//  PHLogoView.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

/// In PHLogoView.xib, you'll notice the view's width is 0, because it's the easiest way to centerize UIViewController.navigationItem.titleView  
/// http://stackoverflow.com/a/30781629/3890662
class PHLogoView: UIView {

    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var leadingTextLabel: UILabel!
    @IBOutlet weak var trailingTextLabel: UILabel!
}
