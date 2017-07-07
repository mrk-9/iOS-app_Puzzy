//
//  PHHubNavigationController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/29/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHHubNavigationController: UINavigationController {
    
    fileprivate var feedButton: UIButton!
    fileprivate var numberOfNewCourseLabel: UILabel!

    var feedBarHidden: Bool {
        set {
            
            self.feedButton.isHidden = newValue
            self.numberOfNewCourseLabel.isHidden = true
            
            if newValue == false {
                PHUser.reloadCurrentUser({[weak self] (response) in
                    
                    guard let user = response.result.value else {
                        return
                    }
                    
                    if user.unreadSubscribedCoursesCount > 99 {
                        
                        self?.numberOfNewCourseLabel.isHidden = false
                        self?.numberOfNewCourseLabel.text = "99+"
                        
                    } else if user.unreadSubscribedCoursesCount > 0 {
                        
                        self?.numberOfNewCourseLabel.isHidden = false
                        self?.numberOfNewCourseLabel.text = String(user.unreadSubscribedCoursesCount)

                    } else {
                        
                        self?.numberOfNewCourseLabel.isHidden = true
                        self?.numberOfNewCourseLabel.text = ""
                    }
                })
            }
        }
        get {
            return self.feedButton.isHidden
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpFeedButton()
        self.feedBarHidden = false
    }
    
    fileprivate func setUpFeedButton() {
        
        let buttonSize: CGFloat = 70.0
        let trailingSpace: CGFloat = 8.0
        
        var buttonFrame = CGRect()
        buttonFrame.size = CGSize(width: buttonSize, height: buttonSize)
        buttonFrame.origin.x = self.view.frame.size.width - buttonFrame.size.width - trailingSpace
        buttonFrame.origin.y = self.view.frame.size.height - buttonFrame.size.height - trailingSpace
        
        self.feedButton = UIButton(frame: buttonFrame)
        
        self.feedButton.autoresizingMask  = [ .flexibleTopMargin, .flexibleLeftMargin ]
        self.feedButton.backgroundColor = UIColor.clear
        self.feedButton.setImage(UIImage(named: "home_icon"), for: UIControlState())
        self.feedButton.addTarget(self, action: #selector(self.feedClick(_:)), for: .touchUpInside)

        self.view.addSubview(self.feedButton)
        
        var labelFrame = CGRect()
        labelFrame.size = CGSize(width: 28.0, height: 21.0)
        labelFrame.origin.x = buttonFrame.origin.x - (labelFrame.size.width / 2.0)
        labelFrame.origin.y = buttonFrame.origin.y - 2.0
        
        self.numberOfNewCourseLabel = UILabel(frame: labelFrame)
        
        self.numberOfNewCourseLabel.autoresizingMask  = [ .flexibleTopMargin, .flexibleLeftMargin ]
        self.numberOfNewCourseLabel.backgroundColor = UIColor(decimalRed: 240, green: 0, blue: 120)
        self.numberOfNewCourseLabel.clipsToBounds = true
        self.numberOfNewCourseLabel.layer.cornerRadius = (labelFrame.size.height - 1.0) / 2.0
        self.numberOfNewCourseLabel.textColor = UIColor.white
        self.numberOfNewCourseLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        self.numberOfNewCourseLabel.isHidden = true
        self.numberOfNewCourseLabel.textAlignment = .center
        
        self.view.addSubview(self.numberOfNewCourseLabel)
    }
    
    func feedClick(_ sender: UIButton) {
        
        if let pageViewController = self.parent as? PHUIPageViewController {
            
            pageViewController.setViewControllers([pageViewController.pageContentViewControllers[0]], direction: .forward, animated: true, completion: nil)
        }
    }
}

extension UIViewController {
    
    var hubNavigationController: PHHubNavigationController? {
        get {
            var viewController = self
            
            while viewController.parent != nil {
                
                if let navigationController = viewController.parent as? PHHubNavigationController {
                    return navigationController
                }
                viewController = viewController.parent!
            }
            return nil
        }
    }
}
