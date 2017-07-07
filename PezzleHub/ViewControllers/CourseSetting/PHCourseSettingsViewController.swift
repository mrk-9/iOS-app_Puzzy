//
//  CourseSettingsVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/14/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import SDWebImage
import Social
import Alamofire

protocol PHCourseSettingsViewControllerDelegate {
    
    func courseSettingsViewController(_ controller: PHCourseSettingsViewController, showViewController: UIViewController)
    func courseSettingsViewControllerDismissViewController(_ controller: PHCourseSettingsViewController)
}

class PHCourseSettingsViewController: UIViewController {

    var delegate: PHCourseSettingsViewControllerDelegate!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var shareLineButton: UIButton!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!

    var course: PHCourse! {
        didSet {
            self.setupShareData()
        }
    }

    var shareText = ""
    var shareImage: UIImage?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let line = URL(string: "line://msg/text/")!
        if UIApplication.shared.canOpenURL(line) == false {
            self.shareLineButton.isEnabled = false
        }
        
        self.ratingLabel.text = String(format: "%0.1f", self.course.rating)
        
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        self.navigationController!.view.backgroundColor = UIColor.clear
    }
    
    // MARK: - Data
    fileprivate func loadData() {
        
        let router = PHRouter.GetCourseComments(courseID: self.course.id)
        
        PHAPIManager.defaultManager.requestArray(router, offset: 0, limit: 100) {[weak self] (response: Alamofire.DataResponse<[PHComment]>) in
            
            let text: String
            
            if response.result.value == nil {
                
                text = "-"
                
            } else if (response.result.value?.count)! > 99 {
                
                text = "99+"
                
            } else {
                
                text = String.init(format: "%d", (response.result.value?.count)!)
            }
            
            self?.commentLabel.text = text
        }
    }

    // MARK: - Actions
    @IBAction func showCalendar(_ sender: AnyObject!) {
        
        let calendarViewController = PHCalendarViewController.instantiate()
        self.navigationController!.pushViewController(calendarViewController, animated: true)
    }

    @IBAction func showCourseDetail(_ sender: AnyObject!) {
        
        let courseViewController = PHCourseViewController.instantiate()
        
        courseViewController.course = self.course
        courseViewController.registerButtonHidden = true
        
        self.dismiss(animated: true) { 
            
            self.delegate.courseSettingsViewController(self, showViewController: courseViewController)
        }
    }

    @IBAction func showUnsubscribeAlert(_ sender: AnyObject!) {

        let animateDuration: TimeInterval = 0.4
        let showContentView = { () -> Void in
        
            UIView.animate(withDuration: animateDuration, animations: {
                self.contentView.alpha = 1.0
            })
        }
        
        let alertController = UIAlertController(title: "コースを削除しますか？", message: nil, preferredStyle: .alert)
        
        let unsubscribeAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            
            self.unsubscribeCourse()
            showContentView()
        }
        alertController.addAction(unsubscribeAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            
            showContentView()
        }
        alertController.addAction(cancelAction)
        
        UIView.animate(withDuration: animateDuration, animations: { 
            
            self.contentView.alpha = 0.0
        
        }, completion: { (completed) in
            
            self.present(alertController, animated: true, completion: nil)
        }) 
    }
    
    @IBAction func showReview(_ sender: AnyObject!) {

        let reviewsViewController = PHCourseReviewsViewController.instantiate()
        
        reviewsViewController.course = self.course
        
        self.navigationController!.pushViewController(reviewsViewController, animated: true)
    }

    // MARK: - Share
    @IBAction func shareFacebook(_ sender: AnyObject!) {

        self.shareSocialService(SLServiceTypeFacebook)
    }

    @IBAction func shareTwitter(_ sender: AnyObject!) {

        self.shareSocialService(SLServiceTypeTwitter)
    }

    @IBAction func shareLine(_ sender: AnyObject!) {

        let text = shareText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let url = URL(string: "line://msg/text/" + text)!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }

    func setupShareData() {
        self.shareText = course.title+" #perzzle"

        let url = URL(string: course.imagePath)
        let dl = SDWebImageDownloader.shared()
        dl?.downloadImage(with: url, options: .useNSURLCache, progress: nil) { [weak self] (image, data, error, flag) in
            self?.shareImage = image
        }
    }

    func shareSocialService(_ serviceType: String) {

        let vc = SLComposeViewController(forServiceType: serviceType)
        vc?.setInitialText(shareText)
        vc?.add(shareImage)
        self.present(vc!, animated: true, completion: nil)
    }

    // MARK: - Data
    fileprivate func unsubscribeCourse() {

        PHAPIManager.defaultManager.requestJSON(.UnsubscribeCourse(courseID: self.course.id)) {[weak self] (response) in
            
            if response.result.isSuccess {
                
                self?.dismiss(animated: true, completion: { 
                    self?.delegate.courseSettingsViewControllerDismissViewController(self!)
                })
            }
        }
    }
}
