//
//  UIViewControllerExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import ObjectiveC

extension UIViewController {
    
    class func instantiate() -> Self {
        
        let className = stringFromClass(self as! AnyClass)
        return UIStoryboard.instantiateViewController(className, storyboardName: className)
    }
    
    @IBAction func dismiss(_ sender: AnyObject!) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func pop(_ sender: AnyObject!) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func popOrDismiss(_ sender: AnyObject!) {
        
        if self === self.navigationController!.viewControllers.first! {
            
            self.dismiss(sender)
            
        } else {
            
            self.pop(sender)
        }
    }
    
    func setUpNavigationTitleView(_ leadingText: String?, trailingText: String?) {
        
        let logoView: PHLogoView = PHLogoView.instantiateFromNib()
        
        if let leadingText = leadingText {
            logoView.leadingTextLabel.text = leadingText
        }
        if let trailingText = trailingText {
            logoView.trailingTextLabel.text = trailingText
        }
        
        self.navigationItem.titleView = logoView
    }
    
    // MARK Presentation
    func presentViewControllerEmbedInNavigationController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        
        let navigationController = UINavigationController(rootViewController: viewControllerToPresent)
        
        self.present(navigationController, animated: flag, completion: completion)
    }
    
    func presentAlert(_ title: String?, message: String?, dismissButtonTitle: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .cancel, handler: nil)
        
        alertController.addAction(dismissAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentAlert(_ title: String?, message: String?, okButtonTitle: String? = "OK", cancelButtonTitle: String = "キャンセル", okHandler: ((UIAlertAction) -> Void)? = nil, cancelHandler: ((UIAlertAction) -> Void)? = nil) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let okButtonTitle = okButtonTitle {
            
            let okAction = UIAlertAction(title: okButtonTitle, style: .destructive, handler: okHandler)
            alertController.addAction(okAction)
        }
        
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel, handler: cancelHandler)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
}

struct PHBarButtonItemInfo {
    let imageName: String
    let target: AnyObject
    let action: Selector
}

// MARK: - BarButtonItem
extension UIViewController {

    func createMultiButtonBarButtonItem(_ itemInfo: [PHBarButtonItemInfo]) -> UIBarButtonItem {

        let space: CGFloat = 4.0
        let buttonSize: CGFloat = 30.0
        let rightInset: CGFloat = 10.0
        let itemCount = itemInfo.count
        let containerWidth = CGFloat(itemCount) * buttonSize + CGFloat(itemCount - 1) * space - rightInset
        let frame = CGRect(x: 0.0, y: 0.0, width: containerWidth, height: buttonSize)
        
        let containerView = UIView(frame: frame)
        
        containerView.backgroundColor = UIColor.clear
        
        var x: CGFloat = 0.0
        
        for info in itemInfo {
            
            let button = self.createButton(info, x: x, buttonSize: buttonSize)
            containerView.addSubview(button)
            
            x += buttonSize + space
        }
        
        let barButtonItem = UIBarButtonItem(customView: containerView)
        
        return barButtonItem
    }
    
    func createMultiButtonBarButtonItem(_ buttonList: [UIButton]) -> UIBarButtonItem {
        
        let space: CGFloat = 4.0
        let buttonSize: CGFloat = 30.0
        let rightInset: CGFloat = 10.0
        let itemCount = buttonList.count
        let containerWidth = CGFloat(itemCount) * buttonSize + CGFloat(itemCount - 1) * space - rightInset
        let frame = CGRect(x: 0.0, y: 0.0, width: containerWidth, height: buttonSize)
        
        let containerView = UIView(frame: frame)
        
        containerView.backgroundColor = UIColor.clear
        
        var x: CGFloat = 0.0
        
        for button in buttonList {
            
            let frame = CGRect(x: x, y: 0.0, width: buttonSize, height: buttonSize)
            button.frame = frame
            containerView.addSubview(button)
            
            x += buttonSize + space
        }
        
        let barButtonItem = UIBarButtonItem(customView: containerView)
        
        return barButtonItem
    }

    func createBarButtonItem(_ itemInfo: PHBarButtonItemInfo) -> UIBarButtonItem {

        let button = self.createButton(itemInfo)
        let barButtonItem = UIBarButtonItem(customView: button)
        
        return barButtonItem
    }
    
    func createButton(_ itemInfo: PHBarButtonItemInfo, x: CGFloat = 0.0, buttonSize: CGFloat = 44.0) -> UIButton {
        
        let frame = CGRect(x: x, y: 0.0, width: buttonSize, height: buttonSize)
        let button = UIButton(frame: frame)
        let image = UIImage(named: itemInfo.imageName)!
        
        button.setImage(image, for: UIControlState())
        button.addTarget(itemInfo.target, action: itemInfo.action, for: .touchUpInside)

        return button
    }
    
    func getTopMostModalViewController() -> UIViewController {
        
        if let presentedViewController = self.presentedViewController {
            return presentedViewController.getTopMostModalViewController()
        }
        return self
    }
    
    
    func getVisibleViewControllerFrom(_ fromViewController: UIViewController?) -> UIViewController? {
        if let navigationController = fromViewController as? UINavigationController {
            return self.getVisibleViewControllerFrom(navigationController.visibleViewController)
        } else if let tabController = fromViewController as? UITabBarController {
            return self.getVisibleViewControllerFrom(tabController.selectedViewController)
        } else {
            if let presentedViewController = fromViewController?.presentedViewController {
                return self.getVisibleViewControllerFrom(presentedViewController)
            } else {
                return fromViewController
            }
        }
    }
}

// MARK: - UIKeyboard
extension UIViewController {
    
    func setUpKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UIViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func tearDownKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        let userInfo = (notification as NSNotification).userInfo!
        
        let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        self.keyboardRectDidChange(keyboardFrame!, animationDuration: duration)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        let duration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        self.keyboardRectDidChange(CGRect.zero, animationDuration: duration)
    }
    
    func keyboardRectDidChange(_ rect: CGRect, animationDuration: TimeInterval) {
        // override here
    }
}

// MARK: - ActivityIndicator
var PHActivityIndicatorKey = "PHActivityIndicator"

protocol PHActivityIndicatorController: class {
    
    func showActivityIndicator()
    func hideActivityIndicator()
}

extension PHActivityIndicatorController where Self: UIViewController {
    
    var activityIndicator: UIActivityIndicatorView? {
        set(newValue) {
            objc_setAssociatedObject(self, &PHActivityIndicatorKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        get {
            return objc_getAssociatedObject(self, &PHActivityIndicatorKey) as? UIActivityIndicatorView
        }
    }

    func showActivityIndicator() {
        
        if self.activityIndicator == nil {
            
            let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
            
            activityIndicatorView.hidesWhenStopped = true
            activityIndicatorView.autoresizingMask = [ .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin ]
            activityIndicatorView.center = self.view.center
            
            self.view.addSubview(activityIndicatorView)
            
            self.activityIndicator = activityIndicatorView
        }
        
        self.view.bringSubview(toFront: self.activityIndicator!)
        self.activityIndicator!.startAnimating()
    }
    
    func hideActivityIndicator() {
        
        self.activityIndicator?.stopAnimating()
    }
}

// MARK: - UINavigationController
extension UINavigationController {
    
    open override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.topViewController?.preferredStatusBarStyle ?? .default
    }
}

// MARK: - enable disble PAGEVIEWCONTROLLER horizonatal scroll
extension UIViewController {
    
    func enablePageControllerScroll() {
        
        if let pageViewController = self.navigationController?.parent as? UIPageViewController {
            
            for view in pageViewController.view.subviews {
                
                if view .isKind(of: UIScrollView.self) {
                    
                    (view as! UIScrollView).isScrollEnabled = true
                    break
                }
            }
        }
    }
    
    func disablePageControllerScroll() {
        
        if let pageViewController = self.navigationController?.parent as? UIPageViewController {
            
            for view in pageViewController.view.subviews {
                
                if view .isKind(of: UIScrollView.self) {
                    
                    (view as! UIScrollView).isScrollEnabled = false
                    break
                }
            }
        }
    }
}
