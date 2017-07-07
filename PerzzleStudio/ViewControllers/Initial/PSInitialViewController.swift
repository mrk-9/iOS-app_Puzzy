//
//  PSInitialViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import BlocksKit

/// Do NOT transit to view except modal transition.
class PSInitialViewController: UIViewController {

    enum State {
        case none
        case signUp
        case main
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

                self.nextState = .main
                self.changeState()
                
            } else {
                
                self.nextState = .signUp
                self.changeState()
            }
            
        case .signUp:
            
            assert(PHAuthManager.isLoggedIn == false, "Check state logic, when self.nextState == .Signup, the user supporse to be logged out.")

            self.nextState = .main
            self.showSignUpView()
        
        case .main:
            
            self.nextState = .none
            self.showMainView()
        }
    }
    
    fileprivate func showSignUpView() {

        let loginViewController = PSLoginViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: loginViewController)
        
        navigationController.modalTransitionStyle = .crossDissolve
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    fileprivate func showMainView() {
        
        let mainViewController = PHMainViewController.instantiate()
        let navigationController = UINavigationController(rootViewController: mainViewController)

        self.present(navigationController, animated: true, completion: nil)
    }
}
