//
//  OwnerVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/12/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class PHOwnerViewController: UIViewController, PHPaginator {

    var owner: PHOwner!
    
    @IBOutlet weak var collectionView: UICollectionView!
    fileprivate var ownerDetailsView = PHOwnerDetailsView()
    fileprivate var refreshControl = UIRefreshControl()

    // MARK: PHPaginator
    typealias DataType = PHCourse
    
    var canGetNextPage = true
    var currentOffset = 0
    var router: PHRouter {
        return .GetUserCourses(userEncryptedID: self.owner.encryptedID)
    }
    var dataList: [DataType] = []
    var isLoading = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.hubBackgroundColor

        self.setUpNavigationTitleView("オーナー", trailingText: "")
        self.setUpOwnerDetailView()
        self.setUpRefreshControl()
        
        self.collectionView.registerCell(PHOwnerCourseCell.self)
        self.collectionView.registerCell(PHLoadingCollectionViewCell.self)
        
        let flowLayout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
        flowLayout.itemSize = CGSize(width: self.view.frame.width / 3.0 - 10, height: 155)
        
        self.loadFirstPage()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }

    fileprivate func setUpOwnerDetailView() {
        
        self.ownerDetailsView.frame.size.width = self.view.frame.width
        self.ownerDetailsView.frame.origin.x = 0
        
        self.ownerDetailsView.imageView.setImageWithPlaceholder(self.owner.imagePath)
        self.ownerDetailsView.ownerNameLabel.text = self.owner.displayName
        self.ownerDetailsView.ownerDescriptionLabel.text = self.owner.description
        
        self.ownerDetailsView.layoutIfNeeded()
        self.ownerDetailsView.frame.origin.y = -self.ownerDetailsView.frame.size.height
        self.collectionView.addSubview(self.ownerDetailsView)

        var contentInset = self.collectionView.contentInset
        contentInset.top += self.ownerDetailsView.frame.size.height
        self.collectionView.contentInset = contentInset
    }
    
    fileprivate func setUpRefreshControl() {
        
        self.refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.collectionView.addSubview(self.refreshControl)
    }
    
    // MARK: - Data
    @objc func loadData() {
        self.loadFirstPage()
    }

    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>) {
        
        self.refreshControl.endRefreshing()
        self.collectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource
extension PHOwnerViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.canGetNextPage ? 2 : 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (indexPath as NSIndexPath).section == 1 {
            return self.collectionView(collectionView, loadingCellForItemAtIndexPath: indexPath)
        }
        
        let cell = collectionView.dequeueReusableCell(PHOwnerCourseCell.self, indexPath: indexPath)
        let course = self.dataList[(indexPath as NSIndexPath).row]
        
        cell.courseImageView.setImageWithPlaceholder(course.imagePath)
//        let placeholderImage = UIImage(named: "placeholder_image")
//        cell.courseImageView.sd_setImage(with: NSURL.fileURL(withPath: course.imagePath), placeholderImage: placeholderImage)
        cell.courseTitleLabel.text = course.title

        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension PHOwnerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let course = self.dataList[(indexPath as NSIndexPath).row]
        let courseViewController = PHCourseViewController.instantiate()
        
        courseViewController.course = course
        courseViewController.isMyCourse = false

        self.navigationController!.pushViewController(courseViewController, animated: true)
    }
}
