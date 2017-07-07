//
//  PSTempLoginViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/4/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

/// PerzzleStudio is an app for Perzzle course owners, they must have an account so there's no SignUp or Forgot Password view right now.
class PSLoginViewController: PHBaseLoginViewController {

    @IBOutlet weak var perzzleStudioWebLabel: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!

    // MARL: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PSLoginViewController.openPezzleStudioWeb(_:)))
        self.perzzleStudioWebLabel.addGestureRecognizer(tap)

        self.bannerImageView.backgroundColor = colorTheme.defaultBackgroundColor
        self.bannerImageView.clipsToBounds = true
        self.bannerImageView.layer.cornerRadius = 8
    }
    
    // MARK: - Actions
    func openPezzleStudioWeb(_ sender: UITapGestureRecognizer) {
        
        let URL = Foundation.URL(string: perzzleStudioPath)!
        UIApplication.shared.openURL(URL)
    }

    @IBAction func openPerzzleApp(_ sender: AnyObject!) {
        
        let URL = Foundation.URL(string: "\(perzzleAppIdentifier)://")!
        let application = UIApplication.shared
        
        if application.canOpenURL(URL) {
            
            application.openURL(URL)

        } else {
            
            let URL = Foundation.URL(string: perzzleAppStoreURL)!
            application.openURL(URL)
        }
    }
    
    @IBAction func showForgotPassrordView() {
        
        let forgotPasswordViewController = PHForgotPasswordViewController.instantiate()
        
        forgotPasswordViewController.defaultEmail = self.emailTextField.text
        
        self.navigationController!.pushViewController(forgotPasswordViewController, animated: true)
    }
}
