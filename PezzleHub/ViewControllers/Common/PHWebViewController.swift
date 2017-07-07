//
//  PHWebViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

class PHWebViewController: UIViewController, PHActivityIndicatorController {

    var path: String!

    @IBOutlet weak fileprivate var webView: UIWebView!
    
    fileprivate var backButton: UIButton!
    fileprivate var forwardButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()

        self.setUpWebView()

        self.backButton = createButton(PHBarButtonItemInfo(imageName: "web_back_button", target: self.webView, action: #selector(self.webView.goBack)))
        self.forwardButton = createButton(PHBarButtonItemInfo(imageName: "web_forward_button", target: self.webView, action: #selector(self.webView.goForward)))
        
        self.backButton.isEnabled = false
        self.forwardButton.isEnabled = false
        
        let rightSideButtonInfo = [
            PHBarButtonItemInfo(imageName: "web_safari_button", target: self, action: #selector(PHWebViewController.openSafari(_:))),
            PHBarButtonItemInfo(imageName: "close_icon", target: self, action: #selector(PHWebViewController.dismiss(_:))),
            ]
        
        self.navigationItem.leftBarButtonItem = self.createMultiButtonBarButtonItem([self.backButton, self.forwardButton])
        self.navigationItem.rightBarButtonItem = self.createMultiButtonBarButtonItem(rightSideButtonInfo)
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpWebView() {
        
        guard let URL = URL(string: self.path) else {
            
            self.presentAlert(nil, message: "ページを開くことができません", dismissButtonTitle: "OK")
            return
        }
        
        let request = URLRequest(url: URL)
        self.webView.loadRequest(request)
    }
    // MARK: - Action
    func openSafari(_ sender: AnyObject!) {
        
        if let url = URL(string: self.path) {
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK: - UIWebViewDelegate
extension PHWebViewController: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
                
        self.showActivityIndicator()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        self.hideActivityIndicator()
        
        if self.title == nil {
            
            self.title = webView.stringByEvaluatingJavaScript(from: "document.title")
        }
        self.backButton.isEnabled = webView.canGoBack
        self.forwardButton.isEnabled = webView.canGoForward
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        self.hideActivityIndicator()
    }
}

extension UIViewController {
    
    func presentWebViewController(_ title: String?, path: String, animated: Bool, completion: (() -> Void)?) {
        
        let webViewController = PHWebViewController.instantiate()
        
        webViewController.title = title
        webViewController.path = path
        
        let navigationController = UINavigationController(rootViewController: webViewController)
        
        self.present(navigationController, animated: animated, completion: completion)
    }
}
