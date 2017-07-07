//
//  PHCategoryListViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/25/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

class PHCategoryListViewController: UIViewController, PHPaginator {

    @IBOutlet weak var tableView: UITableView!

    // MARK: PHPaginator
    typealias DataType = PHCourseCategory
    
    var canGetNextPage = false  // Assuming that the number of course category won't be over 100. To prevent showing a loading cell on the table view.
    var currentOffset = 0
    var limit: Int {
        return 100
    }
    var router: PHRouter = .GetCategories
    var dataList: [DataType] = []
    var isLoading = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.rowHeight = 60.0
        self.tableView.registerCell(PHCategoryCell.self)
        self.tableView.registerCell(PHLoadingTableViewCell.self)

        self.loadFirstPage()
    }

    // MARK: - Data
    @objc func loadData() {
        self.loadFirstPage()
    }

    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>) {
        self.tableView.reloadData()
    }
}

extension PHCategoryListViewController: UITableViewDataSource {
    
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

        let cell = tableView.dequeueReusableCell(PHCategoryCell.self, indexPath: indexPath)
        let category = self.dataList[(indexPath as NSIndexPath).row]
        
        cell.categoryNameLabel.text = category.title
        
        return cell
    }
}

extension PHCategoryListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let category = self.dataList[(indexPath as NSIndexPath).row]
        let courseCategoryViewController = PHCategorizedCourseListController.instantiate()
        
        courseCategoryViewController.title = category.title
        courseCategoryViewController.courseListRouter = PHRouter.GetCourses(isMine: false, parameters: [ "category_id": category.id as AnyObject ])
        
        self.navigationController!.pushViewController(courseCategoryViewController, animated: true)
    }
}

class PHCategorizedCourseListController: PHCourseListController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.hubNavigationController!.feedBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.hubNavigationController!.feedBarHidden = true
        
        super.viewWillDisappear(animated)
    }
}
