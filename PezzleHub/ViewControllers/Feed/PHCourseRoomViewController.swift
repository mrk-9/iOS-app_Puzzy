//
//  CourseRoomVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/12/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import GVUserDefaults
import Alamofire

protocol PHCourseRoomViewControllerExtensions: class {
        
    func setUp()
}

class PHCourseRoomViewController: UIViewController, PHCourseRoomViewControllerExtensions {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chatContainerView: UIView!
    
    var isMyChapters = false
    var course: PHCourse!
    var chapterList: [PHChapter] = []
    
    fileprivate var selectedChapterIndex = 0 {
        didSet {
            guard self.selectedChapterIndex == oldValue else {
                return
            }
            self.selectedChapterProgress = 0.0
        }
    }
    fileprivate var selectedChapterProgress: Float = 0.0
    fileprivate var chatViewControllerList: [PHChatViewController] = []
    var isFinishedCurrentChapter = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        
        self.view.backgroundColor = colorTheme.feedBackgroundColor
        self.chatContainerView.backgroundColor = self.course.category.color
        self.navigationItem.navigationBarHidden = false
        self.navigationItem.navigationBarColor = PHBarColor(tint: self.course.category.color, background: self.course.category.lightColor)
        
        if self.navigationController!.viewControllers.first === self {
            
            let closeImage = UIImage(named: "close_icon")!
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(self.dismiss(_:)))
        }
        
        self.title = self.course.title
        
        self.tableView.registerCell(PHCourseRoomChapterCell.self)
        
        let iconView = PHCourseRoomIconView()
        iconView.imageView.setImageWithPlaceholder(self.course.imagePath)
        
        self.tableView.tableHeaderView = iconView
        
        self.setUp()
        
        self.loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.definesPresentationContext = false
        self.providesPresentationContextTransitionStyle = false
    }
    
    // MARK: - Data
    fileprivate func loadData() {
        
        let router = PHRouter.GetChapters(isMine: self.isMyChapters, courseID: self.course.id)
        let limit = self.course.chaptersCount
        
        PHAPIManager.defaultManager.requestArray(router, offset: 0, limit: limit!) {[weak self] (response: Alamofire.DataResponse<[PHChapter]>) in
            
            guard let chapters = response.result.value else {
                return
            }
            guard chapters.isEmpty == false else {
                return
            }
            
            for chatViewController in self?.chatViewControllerList ?? [] {
                chatViewController.willMove(toParentViewController: nil)
                chatViewController.view.removeFromSuperview()
                chatViewController.removeFromParentViewController()
            }
            
            self?.chatViewControllerList.removeAll()
            
            self?.chapterList = chapters
            
            for chapter in self?.chapterList ?? [] {
                
                let chatViewController = PHChatViewController.instantiate()
                
                chatViewController.isMyPieces = self!.isMyChapters
                chatViewController.delegate = self!
                chatViewController.chapter = chapter
                chatViewController.course = self!.course
                self!.chatViewControllerList.append(chatViewController)
                
                self!.addChildViewController(chatViewController)
                chatViewController.didMove(toParentViewController: self)
            }
            
            var chapterIndex = self!.course.lastReceivedChapterNumber - 1
            
            if chapterIndex < 0 {
                chapterIndex = 0
            }
            
            self?.reloadData(chapterIndex, isFirstLoad: true)
        }
    }
    
    fileprivate func reloadData(_ chapterIndex: Int, isFirstLoad: Bool = false) {
        
        if chapterIndex >= 0 {
            if isFirstLoad == false {
                if chapterIndex == self.selectedChapterIndex {
                    return
                }
                
                let previousChatViewController = self.chatViewControllerList[self.selectedChapterIndex]
                previousChatViewController.view.removeFromSuperview()
            }
            
            let nextChatViewController = self.chatViewControllerList[chapterIndex]
            nextChatViewController.view.frame = self.chatContainerView.bounds
            nextChatViewController.view.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
            self.chatContainerView.addSubview(nextChatViewController.view)
            
            self.selectedChapterIndex = chapterIndex
            let lastCompletedChapter = self.course.lastCompletedChapter != nil ? self.course.lastCompletedChapterNumber : -1
            if lastCompletedChapter >= self.selectedChapterIndex {
                self.isFinishedCurrentChapter = true
            } else {
                self.isFinishedCurrentChapter = false
            }
        }
        
        self.tableView.reloadData()
    }
        
    // MARK: - Actions
    @IBAction func showSettings(_ sender: AnyObject!) {
        
        let courseSettingsViewController = PHCourseSettingsViewController.instantiate()
        
        courseSettingsViewController.delegate = self
        courseSettingsViewController.course = self.course
        
        let navigationController = PHCustomTransitionNavigationController(rootViewController: courseSettingsViewController)
        
        self.presentViewControllerEmbedInPopUpController(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension PHCourseRoomViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chapterList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(PHCourseRoomChapterCell.self, indexPath: indexPath)
        let chapterStatus = self.course.getChapterStatusAtIndex((indexPath as NSIndexPath).row)
        
        let numberText = "\((indexPath as NSIndexPath).row + 1)"
        
        cell.numberLabel.text = numberText
        cell.numberBackgroundLabel.text = numberText
        cell.chapterSelected = ((indexPath as NSIndexPath).row == self.selectedChapterIndex)
        cell.setCategoryColor(self.course.category, chapterStatus: chapterStatus)
        
        if (indexPath as NSIndexPath).row == self.selectedChapterIndex {
        
            cell.setProgress(self.selectedChapterProgress)
            
        } else {
            
            cell.setProgress(1.0)
        }
        
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension PHCourseRoomViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch self.course.getChapterStatusAtIndex((indexPath as NSIndexPath).row) {
        case .delivered:
            
            if (indexPath as NSIndexPath).row == self.selectedChapterIndex {
                
                let cell = tableView.cellForRow(at: indexPath) as! PHCourseRoomChapterCell
                let progressText = "\(Int(self.selectedChapterProgress * 100.0))%"
                
                cell.numberLabel.text = progressText
                cell.numberBackgroundLabel.text = progressText
                
                performAfterDelay(1.0, block: { 
                    
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                })
                
            } else {
                
                self.reloadData((indexPath as NSIndexPath).row)
            }
            
        case .next:
            
            let alertController = UIAlertController(title: "今すぐ配信しますか？", message: nil, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "はい", style: .default, handler: { (action) in
                
                self.isFinishedCurrentChapter = false
                self.reloadData((indexPath as NSIndexPath).row)
                
                self.course.lastReceivedChapter = String(format: "%02d", self.course.lastReceivedChapterNumber + 1)
                
                PHAPIManager.defaultManager.requestObject(.UpdateCourse(isMine: false, course: self.course), completionHandler: {[weak self] (response: Alamofire.DataResponse<PHCourse>) in
                                        
                    guard let _ = response.result.value else {
                        return
                    }
                    
                    self?.course.scheduleNextDeliveryNotification()
                })
            })
            
            let cancelAction = UIAlertAction(title: "いいえ", style: .cancel, handler: nil)
            
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
        case .notDelivered:
            
            guard let nextDeliveryDate = self.course.nextDeliveryDate else {
                break
            }
            
            let message = "次回の配信は"+String(nextDeliveryDate.dateTimeAfterUsingDefaultTimezone())+"です"
            self.presentAlert(nil, message: message, dismissButtonTitle: "OK")
        }
    }
}

// MARK: - PHChatViewControllerDelegate
extension PHCourseRoomViewController: PHChatViewControllerDelegate {
    
    func chatViewController(_ controller: PHChatViewController, didFinishChapter chapter: PHChapter) {
        
        self.course.scheduleNextDeliveryNotification()
        
        self.tableView.reloadData()
    }
    
    func chatViewController(_ controller: PHChatViewController, didChangeProgress progress: Float) {
        
        self.selectedChapterProgress = progress
        
        let indexPath = IndexPath(row: self.selectedChapterIndex, section: 0)
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - PHCourseSettingsViewControllerDelegate
extension PHCourseRoomViewController: PHCourseSettingsViewControllerDelegate {
    
    func courseSettingsViewController(_ controller: PHCourseSettingsViewController, showViewController: UIViewController) {
        
        self.navigationController!.pushViewController(showViewController, animated: true)
    }
    
    func courseSettingsViewControllerDismissViewController(_ controller: PHCourseSettingsViewController) {
        
        self.popOrDismiss(self)
    }
}
