//
//  PHPaginator.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/27/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol PHPaginator: class {
    
    associatedtype DataType

    var canGetNextPage: Bool { get set }
    var currentOffset: Int { get set }
    var limit: Int { get }
    var router: PHRouter { get }
    var dataList: [DataType] { get set }
    var isLoading: Bool { get set }
    
    func didReloadData(_ response: Alamofire.DataResponse<[DataType]>)
}

extension PHPaginator where Self: UIViewController, DataType: PHData {
    
    typealias Completion = (Alamofire.DataResponse<[DataType]>) -> Void

    var limit: Int {
        return 20
    }

    func loadFirstPage() {
        
        self.dataList = []
        self.currentOffset = 0
        self.canGetNextPage = true
        
        self.loadNextPage()
    }
    
    func loadNextPage() {
        
        guard self.canGetNextPage else {
            return
        }
        guard self.isLoading == false else {
            return
        }
        
        self.isLoading = true
        
        PHAPIManager.defaultManager.requestArray(self.router, offset: self.currentOffset, limit: self.limit) {(response: Alamofire.DataResponse<[DataType]>) in
            
            if let error = response.result.error {
                if error._code == -1009 {
                    
                    self.presentAlert(nil, message: "インターネット接続がオフラインのようです。", okButtonTitle: nil, cancelButtonTitle: "閉じる", okHandler: nil, cancelHandler: nil)
                }
            }
            
            guard let data = response.data else {
                return
            }
            guard let responseDataString = String(data: data, encoding: String.Encoding.utf8) else {
                return
            }
            debugPrint(responseDataString)

            guard let results = response.result.value else {
                return
            }
            
            self.updateCurrentOffset(response)
            self.dataList.append(contentsOf: results)
            
            self.didReloadData(response)
            
            self.isLoading = false
        }
        
    }
    
    func updateCurrentOffset(_ response: Alamofire.DataResponse<[DataType]>) {
        
        guard let results = response.result.value else {
            return
        }
        self.currentOffset += results.count

        guard let responseData = response.data else {
            return
        }
        
        let JSONData = JSON(data: responseData)
        let nextPagePath = JSONData["next"].string
        
        self.canGetNextPage = (nextPagePath != nil)
    }
    
    func tableView(_ tableView: UITableView, loadingCellForRowAtIndexPath indexPath: IndexPath) -> PHLoadingTableViewCell {
        
        self.loadNextPage()
        return tableView.dequeueReusableCell(PHLoadingTableViewCell.self, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, loadingCellForItemAtIndexPath indexPath: IndexPath) -> PHLoadingCollectionViewCell {

        self.loadNextPage()
        return collectionView.dequeueReusableCell(withReuseIdentifier: "PHLoadingCollectionViewCell", for: indexPath) as! PHLoadingCollectionViewCell
    }
}
