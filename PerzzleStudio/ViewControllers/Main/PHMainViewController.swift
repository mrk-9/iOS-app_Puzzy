//
//  PHMainViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/25/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHMainViewController: PHTabController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpNavigationbar()
        self.setUpChildViewControllers()
        self.setUpBanner()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpNavigationbar() {
        
        let colorTheme = getColorTheme()

        self.setUpNavigationTitleView(nil, trailingText: "Studio")
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
        
        let settingsImage = UIImage(named: "settings")!
        self.navigationItem.rightBarButtonItem = (UIBarButtonItem().bk_init(with: settingsImage, style: .plain, handler: { (sender) in
            
            let settingsViewController = PHSettingsViewController.instantiate()
            self.presentViewControllerEmbedInNavigationController(settingsViewController, animated: true, completion: nil)
            
        }) as! UIBarButtonItem)
    }
    
    fileprivate func setUpChildViewControllers() {
        
        let colorTheme = getColorTheme()

        let unpublishedCourseViewController = PHCourseChatListController.instantiate()
        unpublishedCourseViewController.courseListRouter = .GetCourses(isMine: true, parameters: [ "is_published": false as AnyObject ])
        unpublishedCourseViewController.isMyCourse = true
        unpublishedCourseViewController.tabViewItem = PHTabViewItem(titleString: "未公開コース")
        unpublishedCourseViewController.view.backgroundColor = colorTheme.defaultBackgroundColor
        
        let publishedCourseViewController = PHCourseChatListController.instantiate()
        publishedCourseViewController.courseListRouter = .GetCourses(isMine: true, parameters: [ "is_published": true as AnyObject ])
        publishedCourseViewController.isMyCourse = true
        publishedCourseViewController.tabViewItem = PHTabViewItem(titleString: "公開済コース")
        publishedCourseViewController.view.backgroundColor = colorTheme.defaultBackgroundColor
        
        self.viewControllers = [
            unpublishedCourseViewController,
            publishedCourseViewController,
        ]
    }
    
    fileprivate func setUpBanner() {
        
        let colorTheme = getColorTheme()
        
        var bannerFrame = self.view.bounds
        bannerFrame.size.height = 30.0
        
        let bannerContainerView = UIView(frame: bannerFrame)
        
        bannerContainerView.backgroundColor = colorTheme.tabBackgroundColor
        bannerContainerView.autoresizingMask = [ .flexibleWidth, .flexibleBottomMargin ]
        bannerContainerView.clipsToBounds = false

        self.view.addSubview(bannerContainerView)
        
        let margin: CGFloat = 8.0
        var imageViewFrame = bannerFrame
        
        imageViewFrame.origin.y += margin
        imageViewFrame.size.height -= 6.0
        
        let bannerImageView = UIImageView(frame: imageViewFrame)
        
        bannerImageView.autoresizingMask = [ .flexibleWidth, .flexibleBottomMargin ]
        bannerImageView.clipsToBounds = false
        bannerImageView.backgroundColor = colorTheme.tabBackgroundColor
        bannerImageView.contentMode = .scaleAspectFit
        bannerImageView.image = UIImage(named: "preview_banner")
        
        bannerContainerView.addSubview(bannerImageView)
        
        self.tabView.frame.origin.y += bannerFrame.origin.y + bannerFrame.size.height
        self.contentView.frame.origin.y = self.tabView.frame.origin.y + self.tabView.frame.size.height
        self.contentView.frame.size.height = self.view.frame.size.height - self.contentView.frame.origin.y
    }
}
