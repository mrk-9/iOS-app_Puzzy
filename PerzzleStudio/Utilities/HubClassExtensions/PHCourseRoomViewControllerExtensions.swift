//
//  PHCourseRoomViewControllerExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/29/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import BlocksKit

extension PHCourseRoomViewControllerExtensions where Self: PHCourseRoomViewController {
    
    func setUp() {
        
        self.isMyChapters = true

        let buttonImage = UIImage(named: "course_detail_button")!
        
        self.navigationItem.rightBarButtonItem = (UIBarButtonItem().bk_init(with: buttonImage, style: .plain, handler: { (sender) in

            let courseViewController = PHCourseViewController.instantiate()
            
            courseViewController.course = self.course
            courseViewController.isMyCourse = self.isMyChapters
            courseViewController.registerButtonHidden = true
            
            self.navigationController!.pushViewController(courseViewController, animated: true)
        })) as? UIBarButtonItem
    }
}
