//
//  CourseReviewsVC.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/15/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import HPGrowingTextView
import Alamofire

class PHCommentInputView: UIView {
    
    var textView: HPGrowingTextView!
    var sendButton: UIButton!
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor(white: 247.0/255.0, alpha: 1.0)
        self.isUserInteractionEnabled = true
        
        self.setUpSendButton()
        self.setUpTextView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setUpSendButton() {
        
        var sendButtonFrame = CGRect.zero
        
        sendButtonFrame.size.width = 60.0
        sendButtonFrame.size.height = 30.0
        sendButtonFrame.origin.x = self.frame.size.width - sendButtonFrame.size.width
        sendButtonFrame.origin.y = (self.frame.size.height - sendButtonFrame.size.height) / 2.0
        
        self.sendButton = UIButton(frame: sendButtonFrame)
        
        self.sendButton.autoresizingMask = [ .flexibleLeftMargin, .flexibleBottomMargin ]
        self.sendButton.setTitleColor(UIColor(white: 142.0/255.0, alpha: 1.0), for: UIControlState())
        self.sendButton.titleLabel!.font = UIFont.boldSystemFont(ofSize: 16)
        self.sendButton.setTitle("送信", for: UIControlState())
        
        self.addSubview(self.sendButton)
    }
    
    fileprivate func setUpTextView() {
        
        self.textView = HPGrowingTextView()
        
        var textViewFrame = CGRect.zero
        
        textViewFrame.origin.x = 8.0
        textViewFrame.size.width = self.frame.size.width - (textViewFrame.origin.x * 2.0) - self.sendButton.frame.size.width
        textViewFrame.size.height = 30.0
        textViewFrame.origin.y = (self.frame.size.height - textViewFrame.size.height) / 2.0
        
        self.textView.frame = textViewFrame
        
        self.textView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        self.textView.backgroundColor = UIColor.white
        
        self.textView.isScrollable = false
        self.textView.placeholder = "コメントを書こう！"
        self.textView.contentInset = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 5.0)
        
        self.textView.minNumberOfLines = 1
        self.textView.maxNumberOfLines = 6
        self.textView.font = UIFont.systemFont(ofSize: 14)
        self.textView.layer.cornerRadius = 5
        self.textView.layer.borderWidth = 1
        self.textView.layer.borderColor = UIColor(white: 200.0/255.0, alpha: 1.0).cgColor
        
        self.textView.returnKeyType = .default
        
        self.addSubview(self.textView)
    }
}

class PHCourseReviewsViewController: UIViewController, PHCommentCellConfiguration, PHPaginator {
    
    var course: PHCourse!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var ratingImageViews: Array<UIImageView>!
    var refreshControl = UIRefreshControl()

    fileprivate var commentInputView: PHCommentInputView!
    
    fileprivate let sendActiveButtonColor = UIColor(red: 4.0/255.0, green: 105.0/255.0, blue: 161.0/255.0, alpha: 1.0)

    // MARK: PHPaginator
    typealias DataType = PHComment
    
    var canGetNextPage = true
    var currentOffset = 0
    var router: PHRouter {
        return .GetCourseComments(courseID: self.course.id)
    }
    var dataList: [DataType] = []
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerCell(PHCommentCell.self)
        self.tableView.registerCell(PHLoadingTableViewCell.self)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.setUpCommentInputView()
        self.setUpRefreshControl()
        self.updateRating()
        
        self.loadFirstPage()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setUpKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.tearDownKeyboardNotifications()
        
        super.viewWillDisappear(animated)
    }
    
    fileprivate func setUpCommentInputView() {
        
        var frame = CGRect.zero
        
        frame.origin.x = 0.0
        frame.size.width = self.view.frame.size.width
        frame.size.height = 50.0
        frame.origin.y = self.view.frame.size.height - frame.size.height
        
        self.commentInputView = PHCommentInputView(frame: frame)
        self.commentInputView.autoresizingMask = [ .flexibleWidth, .flexibleTopMargin ]

        self.commentInputView.textView.delegate = self
        self.commentInputView.sendButton.addTarget(self, action: #selector(PHCourseReviewsViewController.post(_:)), for: UIControlEvents.touchUpInside)
        
        self.commentInputView.isHidden = true
        self.view.addSubview(self.commentInputView)
    }
    
    fileprivate func updateRating() {
        
        let rating = self.course.rating ?? 0.0
        
        for (index, imageView) in self.ratingImageViews.enumerated() {
            
            let imageName = Float(index) < rating ? "rating_star_on" : "rating_star_off"
            imageView.image = UIImage(named: imageName)
        }
    }
    
    fileprivate func setUpRefreshControl() {
        
        self.refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    // MARK: - Data
    @objc func loadData() {
        self.loadFirstPage()
    }
    
    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>) {

        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
    }
    
    // MARK: - Actions
    @IBAction func showReviewTextView(_ sender: AnyObject!) {
        
        self.commentInputView.textView.becomeFirstResponder()
    }
    
    @IBAction func post(_ sender: AnyObject!) {
        
        self.commentInputView.textView.resignFirstResponder()
        
        guard let text = self.commentInputView.textView.text else {
            return
        }
        
        PHAPIManager.defaultManager.requestObject(.PostCourseComments(courseID: self.course.id, text: text)) {[weak self] (response: Alamofire.DataResponse<PHComment>) in
            
            guard let comment = response.result.value else {
                return
            }
                        
            self?.commentInputView.textView.text = nil
            self?.dataList.insert(comment, at: 0)
            
            let indexPath = NSIndexPath.init(row: 0, section: 0)
            
            self?.tableView.insertRows(at: [indexPath as IndexPath], with: .top)
        }
    }
    
    @IBAction func hideKeyboard(_ sender: AnyObject!) {

        self.commentInputView.resignFirstResponder()
    }
    
    // MARK: - UIKeyboard
    override func keyboardRectDidChange(_ rect: CGRect, animationDuration: TimeInterval) {
        
        let isAppearing = rect.size.height > 0.0
        let moveToY = self.view.frame.size.height - (rect.size.height + self.commentInputView.frame.height)
        
        if isAppearing {
            self.commentInputView.isHidden = false
        }
        
        UIView.animate(withDuration: animationDuration, animations: { 
            
            self.commentInputView.frame.origin.y = moveToY
            
        }, completion: { (completed) in
            
            if isAppearing == false {
                
                let animationStartY = self.commentInputView.frame.origin.y
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    self.commentInputView.frame.origin.y = self.view.frame.origin.y + self.view.frame.size.height
                    
                }, completion: { (flag) in
                    
                    self.commentInputView.isHidden = true
                    self.commentInputView.frame.origin.y = animationStartY
                })
            }
        }) 
    }
}

// MARK: HPGrowingTextViewDelegate
extension PHCourseReviewsViewController: HPGrowingTextViewDelegate {

    func growingTextView(_ growingTextView: HPGrowingTextView!, willChangeHeight height: Float) {
        let diff = (growingTextView.frame.size.height - CGFloat(height))
        
        var r = self.commentInputView.frame
        r.size.height -= diff
        r.origin.y += diff
        self.commentInputView.frame = r
    }
    
    func growingTextView(_ growingTextView: HPGrowingTextView!, shouldChangeTextIn range: NSRange, replacementText text: String!) -> Bool {
        
        let newSymbols = self.commentInputView.textView.text.characters.count + (text.characters.count - range.length)
        
        if newSymbols == 0 {
            
            self.commentInputView.sendButton.setTitleColor(UIColor(white: 142.0/255.0, alpha: 1.0), for: UIControlState())
            
        } else {
            
            self.commentInputView.sendButton.setTitleColor(sendActiveButtonColor, for: UIControlState())
        }
        
        return self.commentInputView.textView.text.characters.count + (text.characters.count - range.length) <= 2000
    }
}

// MARK: UITableViewDataSource
extension PHCourseReviewsViewController: UITableViewDataSource {
    
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

        let comment = self.dataList[(indexPath as NSIndexPath).row]

        return self.tableView(tableView, cellForRowAtIndexPath: indexPath, comment: comment)
    }
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    @objc(tableView:estimatedHeightForRowAtIndexPath:) func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

// MARK: - UITableViewDelegate
extension PHCourseReviewsViewController: UITableViewDelegate {
    
}
