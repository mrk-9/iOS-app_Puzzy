//
//  SignupVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

class PHForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet fileprivate weak var credentialsView: UIView!
    
    @IBOutlet fileprivate weak var emailTextField: UITextField!
    
    var defaultEmail: String?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.defaultBackgroundColor

        self.credentialsView.layer.borderColor = colorTheme.credentialBorderColor.cgColor
        
        if let defaultEmail = self.defaultEmail {
            self.emailTextField.text = defaultEmail
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    // MARK: - Action
    @IBAction func backClick(_ sender: AnyObject!) {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func send(_ sender: AnyObject!) {
        
        guard let email = self.emailTextField.text else {
            return
        }
        
        PHAPIManager.defaultManager.requestJSON(.ResetPassword(email: email)) {[weak self] (response: Alamofire.DataResponse<Any>) in
            
            if response.result.isSuccess {
             
                self?.presentAlert("パスワード再設定メールを送信しました", message: "メールを開いてパスワードを再設定してください", dismissButtonTitle: "閉じる")

            } else {
                
                // FixMe: Some better alert
                self?.presentAlert("エラー", message: NSString(data: response.data ?? NSData() as Data, encoding: String.Encoding.utf8.rawValue) as String?, dismissButtonTitle: "閉じる")
            }
        }
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
