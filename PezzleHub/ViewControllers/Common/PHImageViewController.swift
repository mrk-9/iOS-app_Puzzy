//
//  PHImageViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

class PHImageViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var imagePath: String!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpImageView()
        
        let colorTheme = getColorTheme()
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpImageView() {
        
        guard let _ = URL(string: self.imagePath) else {
            
            self.presentAlert(nil, message: "画像を開くことができません", dismissButtonTitle: "OK")
            return
        }
        
        self.imageView.setImageWithPlaceholder(self.imagePath)
    }
}

// MARK: - UIScrollViewDelegate
extension PHImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

extension UIViewController {
    
    func presentImageViewController(_ title: String?, imagePath: String, animated: Bool, completion: (() -> Void)?) {
        
        let imageViewController = PHImageViewController.instantiate()
        
        imageViewController.title = title
        imageViewController.imagePath = imagePath
        
        let navigationController = UINavigationController(rootViewController: imageViewController)
        
        self.present(navigationController, animated: animated, completion: completion)
    }
}
