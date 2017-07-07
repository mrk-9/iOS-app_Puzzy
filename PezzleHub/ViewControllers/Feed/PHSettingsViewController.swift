//
//  SettingsVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/16/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire
import GVUserDefaults

protocol PHSettingsViewControllerExtensions: class {
    
    func setUp()
}

class PHSettingsViewController: UIViewController, PHSettingsViewControllerExtensions {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var notificationSettingsView: UIView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var notificationHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var displaySpeedSlider: UISlider!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var perzzleNumberLabel: UILabel!
    @IBOutlet weak var displayNameTextField: UITextField!
    @IBOutlet weak var displayNameButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var changeProfileImageButton: UIButton!
    @IBOutlet weak var studioBannerView: UIView!

    @IBOutlet weak var versionLabel: UILabel!
    let imagePicker = UIImagePickerController()
    @IBOutlet weak var loadingActivityIndicatorView: UIActivityIndicatorView!

    fileprivate var user: PHUser?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.feedBackgroundColor

        self.setUpNavigationTitleView("設定", trailingText: "")
        self.navigationItem.navigationBarHidden = false
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)

        self.scrollView.contentInset.bottom = self.studioBannerView.frame.size.height
        self.notificationSwitch.isOn = GVUserDefaults.standard().notificationEnabled
        
        self.imagePicker.delegate = self
        self.setUp()

        self.setUpSeekBar()
        self.setUpVersionInfo()
        
        self.loadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        let userDefaults = GVUserDefaults.standard()
        userDefaults?.displaySpeed = self.displaySpeedSlider.value
        
        if self.navigationController!.isBeingDismissed || self.navigationController!.isMovingFromParentViewController {
            
            self.updateProfile()
        }
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - SetUp
    fileprivate func setUpUserData() {
        
        guard let user = self.user else {
            return
        }
        
        self.emailLabel.text = user.email
        self.perzzleNumberLabel.text = user.perzzleNumber
        self.displayNameTextField.text = user.displayName
        self.profileImageView.setImageWithPlaceholder(user.imagePath)

        let userDefaults = GVUserDefaults.standard()
        self.displaySpeedSlider.value = (userDefaults?.displaySpeed)!
    }
    
    fileprivate func setUpSeekBar() {
        
        let seekbarThumb = UIImage(named: "display_speed_slider_thumb")
        self.displaySpeedSlider.setThumbImage(seekbarThumb, for: UIControlState())
        
        let seekbar = UIImage(named: "video_seekbar")!
        let stretchableImage = seekbar.stretchableImage(withLeftCapWidth: 3, topCapHeight: 3)
        self.displaySpeedSlider.setMinimumTrackImage(stretchableImage, for: UIControlState())
        self.displaySpeedSlider.setMaximumTrackImage(stretchableImage, for: UIControlState())
    }
    
    fileprivate func setUpVersionInfo() {
        
        self.versionLabel.text = Bundle.appName+" Ver. "+Bundle.applicationVersion+" ("+Bundle.bundleVersion+")"
    }
    
    // MARK: - Data
    fileprivate func loadData() {
        
        PHUser.reloadCurrentUser {[weak self] (response) in
            
            guard let user = response.result.value else {
                return
            }
            self?.user = user
            self?.setUpUserData()
        }
    }
    
    fileprivate func updateProfile() {
        
        guard let user = self.user else {
            return
        }
        
        var parameters: [String: AnyObject] = [:]
        
        if let displayName = self.displayNameTextField.text {
            if displayName != user.displayName {
                
                parameters["display_name"] = displayName as AnyObject?
            }
        }
        
        guard parameters.count > 0 else {
            return
        }
        
        PHAPIManager.defaultManager.requestObject(.UpdateProfile(parameters: parameters)) {[weak self] (response: Alamofire.DataResponse<PHUser>) in

            guard let user = response.result.value else {
                return
            }
            self?.user = user
            self?.setUpUserData()
        }
    }
    
    // MARK: - Actions
    @IBAction func setNotificationSettings(_ sender: AnyObject!) {

        GVUserDefaults.standard().notificationEnabled = self.notificationSwitch.isOn
    }
    
    @IBAction func logout(_ sender: AnyObject!) {

        self.presentAlert("ログアウトしますか？", message: nil, okButtonTitle: "ログアウト", cancelButtonTitle: "キャンセル", okHandler: { (action) in

            PHAuthManager.deleteTokens()
            
            let appDelegte = UIApplication.shared.delegate as! PHInitialViewControllerAccessor
            appDelegte.revealInitialViewController(self)
            
        }, cancelHandler: nil)
    }
    
    @IBAction func editDisplayName(_ sender: AnyObject!) {
        self.displayNameTextField.becomeFirstResponder()
    }
    
    @IBAction func editProfileImage(_ sender: AnyObject!) {
        self.imagePicker.allowsEditing = true
        self.imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func showAppSettings(_ sender: AnyObject!) {

        let appSettingsViewController = PHAppSettingsViewController.instantiate()
        self.navigationController!.pushViewController(appSettingsViewController, animated: true)
    }
    
    @IBAction func openStudioPage(_ sender: AnyObject!) {
        
        let URL = Foundation.URL(string: perzzleStudioPath)!
        UIApplication.shared.openURL(URL)
    }
}

// MARK: - UITextFieldDelegate
extension PHSettingsViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

//MARK: UIImagePickerControllerDelegate
extension PHSettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        let chosenImage = info[UIImagePickerControllerEditedImage] as! UIImage
        let resizedImage = chosenImage.resizedImage(CGSize(width: 130, height: 130))

        self.loadingActivityIndicatorView.startAnimating()
        self.changeProfileImageButton.isEnabled = false
        
        picker.dismiss(animated: true, completion: {
            
            PHAPIManager.defaultManager.uploadImage(resizedImage) { (response) in
                
                self.loadingActivityIndicatorView.stopAnimating()
                self.changeProfileImageButton.isEnabled = true
                
                if response.result.isFailure {
                    debugPrint(response)
                    let message: String?
                    
                    if let data = response.data {
                        
                        message = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
                        
                    } else {
                        
                        message = nil
                    }
                    
                    //TODO Need to change this message
                    self.presentAlert("Upload image failed", message: message, dismissButtonTitle: "OK")
                } else {
                    
                    DispatchQueue.main.async {
                        self.profileImageView.image = resizedImage
                    }
                    
                }
            }
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
