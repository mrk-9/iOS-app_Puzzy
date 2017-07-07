//
//  PHTabViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import ObjectiveC

class PHTabViewItem {   // Struct cannot be convert to AnyObject
    
    let title: String
    
    init(titleString: String) {
        title = titleString
    }
}

class PHTabController: UIViewController {

    var selectedIndex = 0
    fileprivate(set) var selectedViewController: UIViewController? = nil
    
    var viewControllers: [UIViewController] = [] {
        didSet {
            
            let _ = self.view   // To load self.view

            // Handling previous contentsViewControllers
            if oldValue.count > 0 {
                let previousTopViewController = oldValue[self.selectedIndex]
                previousTopViewController.view.removeFromSuperview()
            }
            
            for childViewController in oldValue {
                
                childViewController.willMove(toParentViewController: nil)
                childViewController.removeFromParentViewController()
            }
            
            // Presenting current contentsViewControllers
            if self.viewControllers.count == 0 {
                self.selectedIndex = 0
                return
            }
            
            var index = 0
            if self.viewControllers.count <= self.selectedIndex {
                index = 0
            }
            
            for childViewController in self.viewControllers {
                
                self.addChildViewController(childViewController)
                childViewController.didMove(toParentViewController: self)
            }
            
            // Setup tabView
            let tabViewItems = self.viewControllers.map { $0.tabViewItem ?? PHTabViewItem(titleString: "") }
            self.tabView.setTabs(tabViewItems, index: self.selectedIndex)

            self.reloadViewController(index)
        }
    }
    
    var tabView: PHTabView!
    var contentView: UIView!
    
    // MARK: - Lifecycle
    override class func instantiate() -> Self {
        
        return self.init()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpTabView()
        self.setUpContentView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        
        guard let topViewController = self.selectedViewController else {
            return .default
        }
        return topViewController.preferredStatusBarStyle
    }
    
    fileprivate func setUpTabView() {
        
        var frame = self.view.bounds
        frame.size.height = 44.0
        
        self.tabView = PHTabView.instantiateFromNib()
        self.tabView.frame = frame
        self.tabView.delegate = self
        
        self.view.addSubview(self.tabView)
    }
    
    fileprivate func setUpContentView() {
        
        var frame = self.view.bounds
        frame.origin.y = self.tabView.frame.origin.y + self.tabView.frame.size.height
        frame.size.height -= frame.origin.y
        
        self.contentView = UIView(frame: frame)
        self.contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.contentView.backgroundColor = UIColor.clear
        
        self.view.addSubview(self.contentView)
        self.view.bringSubview(toFront: self.tabView)
    }
    
    // MARK: - Container Methods
    fileprivate func reloadViewController(_ index: Int) {
        
        guard self.viewControllers.count > 0 else {
            return
        }
        
        let _ = self.view   // To load self.view
        
        if let selectedViewController = self.selectedViewController {
            
            selectedViewController.view.removeFromSuperview()
        }
        
        let nextViewController = self.viewControllers[index]
        nextViewController.view.frame = self.contentView.bounds
        nextViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.contentView.addSubview(nextViewController.view)
        
        self.selectedViewController = nextViewController
        
        self.selectedIndex = index
    }
}

extension PHTabController: PHTabViewDelegate {
    
    func tabView(_ tabView: PHTabView, didSelectIndex index: Int) {

        self.reloadViewController(index)
    }
}

var PHTabViewItemKey = "tabViewItem"

extension UIViewController {
    
    var tabViewController: PHTabController? {
        get {
            var viewController = self
            
            while viewController.parent != nil {
                
                if let tabViewController = viewController.parent as? PHTabController {
                    return tabViewController
                }
                viewController = viewController.parent!
            }
            return nil
        }
    }
    
    var tabViewItem: PHTabViewItem? {
        set(newValue) {
            objc_setAssociatedObject(self, &PHTabViewItemKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &PHTabViewItemKey) as? PHTabViewItem
        }
    }
}
