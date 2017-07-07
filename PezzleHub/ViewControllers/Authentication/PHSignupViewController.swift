//
//  SignupVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHSignupViewController: UIViewController, UITextFieldDelegate, PHActivityIndicatorController {

    @IBOutlet fileprivate weak var credentialsView: UIView!
    
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    @IBOutlet fileprivate weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signUpButtonBottomConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.defaultBackgroundColor
        self.credentialsView.layer.borderColor = colorTheme.credentialBorderColor.cgColor
        
        self.navigationItem.navigationBarHidden = true
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tearDownKeyboardNotifications()
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    // MARK: - Action
    @IBAction func signUpClick() {

        if self.emailTextField.text?.isEmpty == true || self.passwordTextField.text?.isEmpty == true {
            return
        }
        
        self.showActivityIndicator()
        self.signUpButton.isEnabled = false
        
        
        PHAPIManager.defaultManager.signUp(self.emailTextField.text!, password: self.passwordTextField.text!) {[weak self] (response) in
            
            self?.hideActivityIndicator()
            self?.signUpButton.isEnabled = true
            
            if response.result.isFailure {
                debugPrint(response)
                let message: String?
                
                if let data = response.data {
                    
                    message = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String   // FixMe: check api response and show appropriate localized message
                    
                } else {
                    
                    message = nil
                }
                
                self?.presentAlert("サインアップできませんでした", message: message, dismissButtonTitle: "OK")
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
        
        self.signUpButtonBottomConstraint.constant = rect.size.height + 18.0

        UIView.animate(withDuration: animationDuration, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
}
