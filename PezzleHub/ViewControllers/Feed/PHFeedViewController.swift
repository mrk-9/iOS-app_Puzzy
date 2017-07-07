//
//  FeedVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/11/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire
import GVUserDefaults

class PHFeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, PHCourseChatCellConfiguration, PHPaginator {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var pointerImage: UIImageView!

    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()

    var isMyCourse = false
    
    // MARK: PHPaginator
    typealias DataType = PHCourse

    var canGetNextPage = true
    var currentOffset = 0
    var limit: Int {
        return self.customLimit
    }
    var customLimit = 40
    var router: PHRouter = .GetMySubscribedCourses
    var dataList: [DataType] = []
    var isLoading = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.feedBackgroundColor

        let graphView = PHGraphView()
        graphView.frame.size.width = self.view.frame.width
        
//        self.tableView.tableHeaderView = graphView    // For now disable header view because the design and the content is unclear
        self.tableView.registerCell(PHFeedCell.self)
        self.tableView.registerCell(PHLoadingTableViewCell.self)
        self.tableView.contentInset.bottom += PHFeedCell.defaultRowHeight
        
        self.setUpNavigationBar()
        self.setUpRefreshControl()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hideNoSubscriptionMessage(true)
        self.loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.perform(#selector(enablePageControllerScroll), with: nil, afterDelay: 0.1)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.disablePageControllerScroll()
    }

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpNavigationBar() {
        
        let colorTheme = getColorTheme()
        self.setUpNavigationTitleView(nil, trailingText: "Feed")
        self.navigationItem.navigationBarHidden = false
        self.navigationItem.navigationBarColor = PHBarColor(tint: colorTheme.navigationBarMainTintColor, background: colorTheme.navigationBarMainBackgroundColor)
        
        var buttonInfo: [PHBarButtonItemInfo] = []
        
        if PHQRReaderViewController.isVideoDeviceAvailable {
            let info = PHBarButtonItemInfo(imageName: "qr_code", target: self, action: #selector(PHFeedViewController.showQRView(_:)))
            buttonInfo.append(info)
        }
        
        let info = PHBarButtonItemInfo(imageName: "settings", target: self, action: #selector(PHFeedViewController.showSettings(_:)))
        buttonInfo.append(info)
        
        self.navigationItem.rightBarButtonItem = self.createMultiButtonBarButtonItem(buttonInfo)
    }
    
    fileprivate func setUpRefreshControl() {
        
        self.refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }

    func hideNoSubscriptionMessage(_ isHidden: Bool) {
        self.messageLabel.isHidden = isHidden
        self.pointerImage.isHidden = isHidden
    }
    
    // MARK: - Data
    @objc func loadData() {

        self.dataList = []
        self.customLimit = self.currentOffset + self.customLimit
        self.currentOffset = 0
        self.canGetNextPage = true
        self.loadNextPage()
    }

    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>) {

        if self.dataList.count > 0 {
            self.hideNoSubscriptionMessage(true)
        } else {
            self.hideNoSubscriptionMessage(false)
        }

        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func hubClick(_ sender: UIButton) {

        if let pageViewController = self.navigationController?.parent as? PHUIPageViewController {
            
            pageViewController.setViewControllers([pageViewController.pageContentViewControllers[1]], direction: .reverse, animated: true, completion: nil)
        }
    }
    
    func showQRView(_ sender: AnyObject!) {

        let QRViewController = PHQRReaderViewController.instantiate()
        self.presentViewControllerEmbedInNavigationController(QRViewController, animated: true, completion: nil)
    }
    
    func showSettings(_ sender: AnyObject!) {
        
        let settingsViewController = PHSettingsViewController.instantiate()
        self.presentViewControllerEmbedInNavigationController(settingsViewController, animated: true, completion: nil)
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {        
        return self.canGetNextPage ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 1 {
            return self.tableView(tableView, loadingCellForRowAtIndexPath: indexPath)
        }
        
        let course = self.dataList[(indexPath as NSIndexPath).row]
        
        let cell: PHFeedCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath, course: course)

        cell.delegate = self
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.dataList.count > (indexPath as NSIndexPath).row {
            let course = self.dataList[(indexPath as NSIndexPath).row]
            self.showCourseView(course)
        }
    }
    
    func showCourseView(_ course: PHCourse) {
        guard course.isPublished == true else {
            
            self.presentAlert(nil, message: "オーナーの事情により、このコースは非公開となっています", okButtonTitle: "登録を解除する", cancelButtonTitle: "閉じる", okHandler: { (action) in
                
                PHAPIManager.defaultManager.requestJSON(.UnsubscribeCourse(courseID: course.id), completionHandler: {[weak self] (response) in
                    
                    if response.result.isSuccess {
                        
                        PHUser.reloadCurrentUser()
                        
                        let index = self?.dataList.index { $0.id == course.id }
                        self?.dataList.remove(at: index!)
                        self?.tableView.reloadData()
                    }
                    })
                
                }, cancelHandler: { (action) in
                    
            })
            
            return
        }
        
        let courseViewController = PHCourseRoomViewController.instantiate()
        
        courseViewController.course = course
        
        self.navigationController!.pushViewController(courseViewController, animated: true)
    }
}

extension PHFeedViewController: PHFeedCellDelegate {
    //MARK: - push chat view on drag left
    func pushDetailView(_ cell: PHFeedCell) {
        
        if let indexPath = self.tableView.indexPath(for: cell) {
            
            let course = self.dataList[(indexPath as NSIndexPath).row]
            self.showCourseView(course)
        }
    }
}
