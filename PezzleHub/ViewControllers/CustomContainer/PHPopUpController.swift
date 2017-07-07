//
//  PHPopupViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/20/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHPopUpController: UIViewController {

    fileprivate(set) var topViewController: UIViewController
    fileprivate var contentView: UIView!
    fileprivate var blurEffectView: UIVisualEffectView!
    
    // MARK: - Lifecycle
    init(rootViewController: UIViewController) {
        
        topViewController = rootViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpBlurView()
        self.setUpContentView()
        self.setUpTopViewController()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent    // FixMe: Not working (modalPresentationStyle affects maybe..?)
    }
    
    // MARK: - SetUp
    fileprivate func setUpBlurView() {
        
        let blurEffect = UIBlurEffect(style: .dark)
        self.blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        self.blurEffectView.frame = self.view.bounds
        self.blurEffectView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]

        self.view.addSubview(self.blurEffectView)
    }
    
    fileprivate func setUpContentView() {
        
        self.contentView = UIView(frame: self.view.bounds)
        self.contentView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        
        self.view.addSubview(self.contentView)
    }
    
    fileprivate func setUpTopViewController() {
        
        self.addChildViewController(self.topViewController)

        self.topViewController.view.frame = self.contentView.bounds
        self.topViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.contentView.addSubview(self.topViewController.view)
        
        self.topViewController.didMove(toParentViewController: self)
    }
}

extension UIViewController {
    
    var popupController: PHPopUpController? {
        get {
            var viewController = self
            
            while viewController.parent != nil {
                
                if let popUpController = viewController.parent as? PHPopUpController {
                    return popUpController
                }
                viewController = viewController.parent!
            }
            return nil
        }
    }
    
    func presentViewControllerEmbedInPopUpController(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        
        let popUpController = PHPopUpController(rootViewController: viewControllerToPresent)
        
        self.definesPresentationContext = true
        self.providesPresentationContextTransitionStyle = true
        
        popUpController.modalTransitionStyle = .crossDissolve
        popUpController.modalPresentationStyle = .overFullScreen

        self.present(popUpController, animated: flag, completion: completion)
    }
}
