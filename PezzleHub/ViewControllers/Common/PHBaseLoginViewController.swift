//
//  PHBaseLoginViewController.swift
//  PezzleHub
//
//  Created by Rajinder Paul on 02/06/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHBaseLoginViewController: UIViewController, UITextFieldDelegate, PHActivityIndicatorController {
    @IBOutlet weak var credentialsView: UIView!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var loginButtonBottomConstraint: NSLayoutConstraint!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.defaultBackgroundColor
        
        self.credentialsView.layer.borderColor = colorTheme.credentialBorderColor.cgColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        self.setUpKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tearDownKeyboardNotifications()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Actions
    @IBAction func loginClick() {
        
        if self.emailTextField.text == nil || self.passwordTextField.text == nil {
            return
        }
        
        self.showActivityIndicator()
        self.loginButton.isEnabled = false
        
        PHAPIManager.defaultManager.login(self.emailTextField.text!, password: self.passwordTextField.text!) {[weak self] (response) in
            
            self?.hideActivityIndicator()
            self?.loginButton.isEnabled = true
            
            if response.result.isFailure {
                debugPrint(response)
                self?.presentAlert("ログインできませんでした", message: "アカウントとパスワードを確認してください", dismissButtonTitle: "OK")
                return
            }
            
            self?.dismiss(self)
        }
    }
    
    @IBAction func hideKeyboard(_ sender: AnyObject!) {
        
        self.emailTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    //MARK: - Keyboard notification observer methods
    override func keyboardRectDidChange(_ rect: CGRect, animationDuration: TimeInterval) {

        self.loginButtonBottomConstraint.constant = rect.size.height + 18.0
        
        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
}
