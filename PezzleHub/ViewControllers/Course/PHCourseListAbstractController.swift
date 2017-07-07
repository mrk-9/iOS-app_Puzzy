//
//  PHCourseListAbstractController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

protocol PHCourseListControllerDelegate: class {
    
    func courseListController(_ controller: PHCourseListAbstractController, didLoadCourses courses: [PHCourse]?)
}

extension PHCourseListControllerDelegate {
    
    func courseListController(_ controller: PHCourseListAbstractController, didLoadCourses courses: [PHCourse]?) {
        // Default implementation. Does nothing.
    }
}

/// Use PHCourseListController or PHCourseChatListController
class PHCourseListAbstractController: UIViewController, UITableViewDataSource, UITableViewDelegate, PHPaginator {    // Do NOT split into extensions for each protocols. Overriding extended functions causes redefinition error

    // Could be nil, when searching courses (PHSearchViewController)
    var courseListRouter: PHRouter! {
        didSet {
            assert(courseListRouter.isCourseRouter, String(describing: self.courseListRouter)+" doesn't have response type of [PHCourse]")
            
            if self.isViewLoaded {
                self.loadData()
            }
        }
    }
    var delegate: PHCourseListControllerDelegate?
    var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    // MARK: PHPaginator
    typealias DataType = PHCourse

    var canGetNextPage = true
    var currentOffset = 0
    var router: PHRouter {
        return self.courseListRouter
    }
    var dataList: [DataType] = []
    var isLoading = false

    override class func instantiate() -> Self {
        return self.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorTheme = getColorTheme()
        self.view.backgroundColor = colorTheme.defaultBackgroundColor
        
        self.setUpTableView()
        self.setUpRefreshControl()
        
        self.loadFirstPage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func setUpTableView() {
        
        self.tableView = UITableView(frame: self.view.bounds, style: .plain)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.separatorStyle = .none
        self.tableView.alwaysBounceVertical = true
        self.tableView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        
        self.tableView.registerCell(PHLoadingTableViewCell.self)

        self.view.addSubview(self.tableView)
    }
    
    fileprivate func setUpRefreshControl() {
        
        self.refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }

    // MARK: - Data
    @objc func loadData() {
        
        guard let _ = self.courseListRouter else {
            
            self.dataList = []
            self.tableView.reloadData()
            return
        }
        
        self.loadFirstPage()
    }
    
    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>) {

        self.refreshControl.endRefreshing()
        self.delegate?.courseListController(self, didLoadCourses: response.result.value)
        self.tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.canGetNextPage ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Use PHCourseListController or PHCourseChatListController")
    }
    
    // MARK: - UITableViewDelegate
}
