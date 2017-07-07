//
//  ViewController.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

class PHHubViewController: PHTabController {
        
    var searchBar = PHSearchBarContainerView()
    var searchButton: UIButton?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        self.view.backgroundColor = colorTheme.hubBackgroundColor
        
        self.setUpNavigationBar()
        self.setUpChildViewControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hubNavigationController!.feedBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.hubNavigationController!.feedBarHidden = true

        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.perform(#selector(enablePageControllerScroll), with: nil, afterDelay: 0.1)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.disablePageControllerScroll()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpNavigationBar() {
        
        let colorTheme = getColorTheme()

        self.setUpNavigationTitleView(nil, trailingText: "Hub")
        self.navigationItem.navigationBarHidden = false
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
        
        var buttonInfo: [PHBarButtonItemInfo] = []
        
        if PHQRReaderViewController.isVideoDeviceAvailable {
            let info = PHBarButtonItemInfo(imageName: "qr_code", target: self, action: #selector(PHHubViewController.showQRView(_:)))
            buttonInfo.append(info)
        }
        
        let info = PHBarButtonItemInfo(imageName: "magnifying_glass", target: self, action: #selector(PHHubViewController.showSearchBar(_:)))
        buttonInfo.append(info)
        
        self.navigationItem.rightBarButtonItem = self.createMultiButtonBarButtonItem(buttonInfo)
    }

    fileprivate func setUpChildViewControllers() {
        
        let featuredCourseViewController = PHCourseListController.instantiate()
        featuredCourseViewController.courseListRouter = PHRouter.GetCourses(isMine: false, parameters: [ "is_featured": true as AnyObject ])
        featuredCourseViewController.tabViewItem = PHTabViewItem(titleString: "おすすめ")
        
        let categoryViewController = PHCategoryListViewController.instantiate()
        categoryViewController.tabViewItem = PHTabViewItem(titleString: "カテゴリー")
        
        let ownerViewController = PHOwnerListViewController.instantiate()
        ownerViewController.tabViewItem = PHTabViewItem(titleString: "オーナー")

        self.viewControllers = [
            featuredCourseViewController,
            categoryViewController,
            ownerViewController,
        ]
    }
    
    // MARK: - Actions
    func showQRView(_ sender: AnyObject!) {
        
        let QRViewController = PHQRReaderViewController.instantiate()
        self.presentViewControllerEmbedInNavigationController(QRViewController, animated: true, completion: nil)
    }
    
    func showSearchBar(_ sender: AnyObject!) {
        
        let searchViewController = PHSearchViewController.instantiate()
        
        searchViewController.modalTransitionStyle = .crossDissolve
        
        self.presentViewControllerEmbedInNavigationController(searchViewController, animated: true, completion: nil)
    }
}
