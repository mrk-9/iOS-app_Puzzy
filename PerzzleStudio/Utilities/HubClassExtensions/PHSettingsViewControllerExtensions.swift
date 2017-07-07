//
//  PHSettingsViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/29/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

extension PHSettingsViewControllerExtensions where Self: PHSettingsViewController {
    
    func setUp() {
        
        self.notificationSettingsView.isHidden = true
        self.notificationHeightConstraints.constant = 0.0
        
        self.displayNameButton.isHidden = true
        self.changeProfileImageButton.isHidden = true
        
        self.displayNameTextField.isUserInteractionEnabled = false
        
        self.studioBannerView.isHidden = true
        
        self.view.layoutIfNeeded()
    }
}
