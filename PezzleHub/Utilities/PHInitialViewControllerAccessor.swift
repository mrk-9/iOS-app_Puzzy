//
//  PHInitialViewControllerAccessor.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHInitialViewControllerAccessor: class {
    
    var initialViewController: UIViewController { get }
    
    func revealInitialViewController(_ sender: AnyObject)
}

extension PHInitialViewControllerAccessor {
    
    func revealInitialViewController(_ sender: AnyObject) {
    
        self.initialViewController.dismiss(sender)
    }
}
