//
//  SignupVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHLoginViewController: PHBaseLoginViewController {

    // MARL: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    @IBAction func signUpClick() {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func forgotPassrord() {
        
        let forgotPasswordViewController = PHForgotPasswordViewController.instantiate()
        
        forgotPasswordViewController.defaultEmail = self.emailTextField.text
        
        self.navigationController!.pushViewController(forgotPasswordViewController, animated: true)
    }
}
