//
//  PHInitialViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

/// This ViewController manages which ViewController comes after launch. OnBoarding, SignUp, Feed, etc
/// Do NOT transit to view except modal transition.
class PHInitialViewController: UIViewController {

    enum State {
        case none
        case signUp
        case feed
    }
    
    fileprivate var nextState = State.none
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.defaultBackgroundColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.changeState()
    }
    
    // MARK: - State
    fileprivate func changeState() {
        
        switch self.nextState {
        case .none:
            
            if PHAuthManager.isLoggedIn {
                
                self.nextState = .feed
                self.changeState()
                
            } else {
                
                self.nextState = .signUp
                self.changeState()
            }
            
        case .signUp:
            self.nextState = .feed
            self.showSignUpView()

        case .feed:
            
            self.nextState = .none
            self.showFeedView()
        }
    }
    
    fileprivate func showSignUpView() {
        
        let signUpViewController = PHSignupViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: signUpViewController)
    
        navigationController.modalTransitionStyle = .crossDissolve
    
        self.present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func showFeedView() {
        
        let feedViewController = PHFeedViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: feedViewController)
        navigationController.modalTransitionStyle = .coverVertical
        
        let hubNavigationController = PHHubNavigationController.instantiate()
        
        let pageController = PHUIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

        pageController.pageContentViewControllers = [
            navigationController,
            hubNavigationController
        ]

        pageController.dataSource = self
        pageController.setViewControllers([pageController.pageContentViewControllers[0]], direction: UIPageViewControllerNavigationDirection.reverse, animated: true, completion: nil)

       self.present(pageController, animated: true, completion: nil)
    }
}

class PHUIPageViewController: UIPageViewController {
    var pageContentViewControllers: [UIViewController] = []

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: UIPageViewController DataSource
extension PHInitialViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let phPageViewController = pageViewController as? PHUIPageViewController {

            if let index = phPageViewController.pageContentViewControllers.index(of: viewController) {

                if index <  phPageViewController.pageContentViewControllers.count - 1 {
                    return phPageViewController.pageContentViewControllers[index + 1]
                }
            }
        }

        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if let phPageViewController = pageViewController as? PHUIPageViewController {
            
            if let index = phPageViewController.pageContentViewControllers.index(of: viewController) {

                if index > 0 {
                    return phPageViewController.pageContentViewControllers[index - 1]
                }
            }
        }

        return nil
    }
}
