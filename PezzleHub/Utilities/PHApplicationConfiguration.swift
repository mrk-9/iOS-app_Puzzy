//
//  PHApplicationAppearanceConfiguration.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import Mixpanel
import GVUserDefaults

protocol PHApplicationConfiguration {
    
    func setUp()
}

extension PHApplicationConfiguration {
    
    func setUp() {
        
        self.setUpFabric()
        self.setUpMixpanel()
        self.setUpSettingsBundle()
        self.setUpApplicationAppearance()
    }

    fileprivate func setUpFabric() {
        
        Fabric.with([Crashlytics.self])
    }

    fileprivate func setUpMixpanel() {
        
        // Documentation https://mixpanel.com/help/reference/ios
        // Push Notification Developer Guide https://mixpanel.com/help/reference/ios-push-notifications
        let mixPanelKey = Bundle.externalServiceKeys["MixpanelToken"]!
        Mixpanel.sharedInstance(withToken: mixPanelKey)
        
//        let mixpanelInstance = Mixpanel.sharedInstance()
//        mixpanelInstance.identify(<#T##distinctId: String##String#>)
    }

    fileprivate func setUpSettingsBundle() {
        
        let userDefaults = GVUserDefaults.standard()
        userDefaults?.bundleAppVersionInfo = "\(Bundle.applicationVersion) (\(Bundle.bundleVersion))"
    }
    
    fileprivate func setUpApplicationAppearance() {
        
        // NavigationBar Appearance
        let navigationBarAppearance = UINavigationBar.appearance()
        
        navigationBarAppearance.isTranslucent = false
        
        // Removes shadow
        navigationBarAppearance.shadowImage = UIImage()
        
        // Replaces navigation back button image
        navigationBarAppearance.backIndicatorImage = UIImage(named: "back_button")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        navigationBarAppearance.backIndicatorTransitionMaskImage = UIImage(named: "back_button")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        
        // Removes navigation back button texts
        (try! UIViewController.aspect_hook(#selector(UIViewController.viewDidLoad), with: .positionBefore) { (aspectInfo) in
            
            let viewController = aspectInfo?.instance() as! UIViewController
            let klass = type(of: viewController)
            let className = stringFromClass(klass)
            
            let classPrefixesWithoutBackButtonText = [
                "PH",
                "PS",
                "VTAcknowledgementsViewController",
                "VTAcknowledgementViewController",
            ]
            
            if (classPrefixesWithoutBackButtonText.contains { className.hasPrefix($0) == false }) == false {
                return
            }
            
            viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        })
        
        // Extend UIViewController.viewWillAppear(_:)

        
        (try! UIViewController.aspect_hook(#selector(UIViewController.viewWillAppear(_:)), with: .positionBefore, usingAspectBlock: { (aspectInfo) in
            
            let viewController = aspectInfo?.instance() as! UIViewController
            
            if let navigationBarHidden = viewController.navigationItem.navigationBarHidden {
                
                viewController.navigationController?.setNavigationBarHidden(navigationBarHidden, animated: true)
            }
            
            if let navigationBarColor = viewController.navigationItem.navigationBarColor {
                
                viewController.navigationController?.navigationBar.setColor(navigationBarColor)
            }
        }))
    }
}
