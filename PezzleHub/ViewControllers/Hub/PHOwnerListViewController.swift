//
//  PHOwnerListViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/25/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

class PHOwnerListViewController: UIViewController, PHPaginator {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    
    // MARK: PHPaginator
    typealias DataType = PHOwner
    
    var canGetNextPage = true
    var currentOffset = 0
    var router: PHRouter = .GetFeaturedStudioUser
    var dataList: [DataType] = []
    var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 96.0
        self.tableView.registerCell(PHOwnerCell.self)
        self.tableView.registerCell(PHLoadingTableViewCell.self)

        self.setUpRefreshControl()
        self.loadFirstPage()
    }
    
    fileprivate func setUpRefreshControl() {
        
        self.refreshControl.addTarget(self, action: #selector(self.loadData), for: .valueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    // MARK: - Data
    @objc func loadData() {
        
        self.refreshControl.endRefreshing()
        self.loadFirstPage()
    }
    
    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>) {
        self.tableView.reloadData()
    }
}

extension PHOwnerListViewController: UITableViewDataSource {
    
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

        let cell = tableView.dequeueReusableCell(PHOwnerCell.self, indexPath: indexPath)
        let owner = self.dataList[(indexPath as NSIndexPath).row]
        
        cell.ownerImageView.setImageWithPlaceholder(owner.imagePath)
        cell.ownerName = owner.displayName
        cell.ownerDescription = owner.description
        
        return cell
    }
}

extension PHOwnerListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let ownerViewController = PHOwnerViewController.instantiate()
        let owner = self.dataList[(indexPath as NSIndexPath).row]
                
        ownerViewController.owner = owner
        
        self.navigationController!.pushViewController(ownerViewController, animated: true)
    }
}
