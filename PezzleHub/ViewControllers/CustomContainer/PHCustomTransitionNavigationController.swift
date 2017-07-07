//
//  PHCustomTransitionNavigationController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/20/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHCustomTransitionNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - 
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if animated {
            
            UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
                
                super.pushViewController(viewController, animated: false)

            }, completion: nil)
            
        } else {
            
            super.pushViewController(viewController, animated: false)
        }
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        var viewController: UIViewController!
        
        if animated {
            
            UIView.transition(with: self.view, duration: 0.4, options: .transitionCrossDissolve, animations: {
                
                viewController = super.popViewController(animated: false)
                
            }, completion: nil)

        } else {
            
            viewController = super.popViewController(animated: false)
        }
        
        return viewController
    }
}
