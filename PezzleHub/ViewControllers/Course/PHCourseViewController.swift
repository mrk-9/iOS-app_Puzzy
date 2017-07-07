//
//  PieceVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire
import GVUserDefaults

class PHCourseViewController: UIViewController, PHCourseDetailViewConfiguration {
    
    var registerButtonHidden = false
    
    @IBOutlet weak var hashtagsCollectionView: UICollectionView!
    @IBOutlet weak var previewsCollectionView: UICollectionView!
    @IBOutlet weak var previewsCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesView: UIPageControl!
    
    @IBOutlet weak var chaptersView: UIView!
    @IBOutlet weak var chaptersHeight: NSLayoutConstraint!
    @IBOutlet weak var hashtagsHeight: NSLayoutConstraint!
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    @IBOutlet weak var courseDetailView: PHCourseDetailView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var authorDescriptionLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    @IBOutlet weak var deliveryDescriptionLabel: UILabel!
    
    @IBOutlet weak var registerButtonContainerView: UIView!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var registerButtonWidthConstraint: NSLayoutConstraint!
    
    var isMyCourse = false
    var course: PHCourse!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.hubBackgroundColor
        
        self.setUpNavigationTitleView(nil, trailingText: "Hub")
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
        
        self.setUpCourseDetailView()
        self.setUpHashtags()
        self.setUpChapters()
        self.setUpOwnerInfo()
        self.setUpRegisterButton()
        
        self.deliveryDescriptionLabel!.text = self.course.deliveryDateDescriptionString
        
        self.pagesView.numberOfPages = self.course.previewImages.count
        
        self.viewWidth.constant = self.view.frame.width
        self.registerButtonWidthConstraint?.constant = self.view.frame.size.width - 40.0
        self.view.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateRegisterButton()
        
        self.registerButtonContainerView.isHidden = self.registerButtonHidden
        self.registerButton.isUserInteractionEnabled = true
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpCourseDetailView() {
        
        self.configureCourseDetailView(self.courseDetailView, course: self.course)
    }
    
    fileprivate func setUpHashtags() {
        
        self.hashtagsCollectionView.reloadData()
        self.hashtagsCollectionView.layoutIfNeeded()
        self.hashtagsHeight.constant = self.hashtagsCollectionView.contentSize.height
        self.view.layoutIfNeeded()
    }
    
    fileprivate func setUpOwnerInfo() {
        
        self.descriptionLabel.text = self.course.description
        self.authorLabel.text = self.course.owner.username
        self.authorDescriptionLabel.text = self.course.owner.description
        self.authorImageView.setImageWithPlaceholder(self.course.owner.imagePath)
    }
    
    fileprivate func setUpChapters() {
        
        let router = PHRouter.GetChapters(isMine: self.isMyCourse, courseID: self.course.id)
        
        PHAPIManager.defaultManager.requestArray(router, offset: 0, limit: 100) {[weak self] (response: Alamofire.DataResponse<[PHChapter]>) in
            
            guard let chapters = response.result.value else {
                return
            }
            
            _ = self?.chaptersView.subviews.map { $0.removeFromSuperview() }
            
            var totalHeight: CGFloat = 0
            
            for (_, value) in chapters.enumerated() {
                let chapterView = PHChapterView()
                chapterView.numberLabel.text = "第"+value.number+"回"
                chapterView.titleLabel.text = value.title
                chapterView.frame.size.width = self?.chaptersView.frame.width ?? 0.0
                chapterView.frame.origin.y = totalHeight
                chapterView.frame.origin.x = 0
                totalHeight += chapterView.frame.height + 3
                
                
                self?.chaptersView.addSubview(chapterView)
            }
            self?.chaptersHeight.constant = totalHeight
        }
    }
    
    fileprivate func setUpRegisterButton() {
        
        self.registerButtonContainerView.backgroundColor = self.view.backgroundColor
        self.registerButtonContainerView.clipsToBounds = false
        self.registerButtonContainerView.layer.shadowColor = UIColor(white: 0.2, alpha: 1.0).cgColor
        self.registerButtonContainerView.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
        self.registerButtonContainerView.layer.shadowOpacity = 0.4
        self.registerButtonContainerView.layer.shadowRadius = 1.0
    }
    
    fileprivate func updateRegisterButton() {
        
        if self.course.isSubscribed {
            
            self.registerButton.backgroundColor = UIColor(decimalRed: 222, green: 222, blue: 222)
            self.registerButton.setTitle("コース登録を解除", for: UIControlState())
            
        } else {
            
            self.registerButton.backgroundColor = UIColor(decimalRed: 51, green: 51, blue: 51)
            self.registerButton.setTitle("コース登録", for: UIControlState())
        }
    }
    
    // MARK: - Actions
    @IBAction func registerCourse(_ sender: AnyObject!) {
                
        if self.course.isSubscribed {
            // unregister
            
            self.registerButton.isUserInteractionEnabled = false
            
            PHAPIManager.defaultManager.requestJSON(.UnsubscribeCourse(courseID: self.course.id)) {[weak self] (response) in
                
                self?.registerButton.isUserInteractionEnabled = true

                if response.result.isSuccess {

                    PHUser.reloadCurrentUser({ (response) in
                        self?.updateRegisterButton()
                    })
                }
            }

        } else {
            // register
            
            self.registerButton.isUserInteractionEnabled = false

            PHAPIManager.defaultManager.requestObject(.SubscribeCourse(courseID: self.course.id)) {[weak self] (response: Alamofire.DataResponse<PHCourse>) in
                
                self?.registerButton.isUserInteractionEnabled = true

                if response.result.isSuccess {
                    
                    PHUser.reloadCurrentUser({ (response) in
                        self?.updateRegisterButton()
                    })
                    
                    self?.course.scheduleNextDeliveryNotification()
                    
                    self?.dismiss(self) // Return to Feed view
                }
            }
        }
    }
    
    @IBAction func registerButtonTouchDownInside(_ sender: AnyObject!) {
        
        self.registerButtonWidthConstraint?.constant = self.view.frame.size.width - 20.0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
    
    @IBAction func registerButtonTouchUp(_ sender: AnyObject!) {
        
        self.registerButtonWidthConstraint?.constant = self.view.frame.size.width - 40.0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) 
    }
}

// MARK: - UICollectionViewDataSource
extension PHCourseViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.hashtagsCollectionView {
            
            return self.course.hashtags.count
            
        } else {
            
            let count = self.course.previewImages.count
            
            if count > 0 {
                
                self.previewsCollectionView.isHidden = false
                self.previewsCollectionViewHeightConstraint.constant = 250.0
                
            } else {

                self.previewsCollectionView.isHidden = true
                self.previewsCollectionViewHeightConstraint.constant = 0.0
            }
            self.previewsCollectionView.layoutIfNeeded()
            
            return count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView === self.hashtagsCollectionView {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "hashtagCell", for: indexPath)
            
            let categoryColor = self.course.category.color
            cell.backgroundColor = categoryColor
            
            let hashtagLabel = cell.viewWithTag(1) as! UILabel
            hashtagLabel.text = self.course.hashtags[(indexPath as NSIndexPath).row].text
            
            return cell
            
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreviewCell", for: indexPath)
            
            let path = self.course.previewImages[(indexPath as NSIndexPath).row]
            let imageView = cell.viewWithTag(1) as! UIImageView
            imageView.setImageWithPlaceholder(path)
            
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension PHCourseViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView === self.hashtagsCollectionView {
            let hashtag = course.hashtags[(indexPath as NSIndexPath).row].text as NSString
            let maximumLabelSize = CGSize(width: self.view.frame.size.width, height: 20)
            let expectedLabelRect = hashtag.boundingRect(with: maximumLabelSize, options: [], attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 16)], context: nil)
            return CGSize(width: expectedLabelRect.size.width + 25, height: 20)
        } else {
            return CGSize(width: 165, height: 250)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView === self.hashtagsCollectionView {
            return UIEdgeInsets.zero
        } else {
            return UIEdgeInsetsMake(0, (self.view.frame.width - 165.0)/2.0, 0, (self.view.frame.width - 165.0)/2.0)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension PHCourseViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView === self.previewsCollectionView {
            
            let path = self.course.previewImages[(indexPath as NSIndexPath).row]
            
            self.presentImageViewController("プレビュー", imagePath: path, animated: true, completion: nil)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension PHCourseViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView === self.previewsCollectionView {
            let pageNumber = (scrollView.contentOffset.x) / 170.0
            self.pagesView.currentPage = Int(round(pageNumber))
        }
    }
    
}
