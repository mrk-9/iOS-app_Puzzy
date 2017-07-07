//
//  PHCourseChatViewController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

/// ViewController with listed courses, for Perzzle Feed. Selecting a cell transits to PHCourseRoomViewController (chat view).
/// For Perzzle Hub, use PHCourseListController.
class PHCourseChatListController: PHCourseListController, PHCourseChatCellConfiguration {

    var isMyCourse = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.registerCell(PHFeedCell.self)
        self.tableView.rowHeight = PHFeedCell.defaultRowHeight
    }

    // MARK: - UITableViewDataSoure
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 1 {
            return self.tableView(tableView, loadingCellForRowAtIndexPath: indexPath)
        }

        let course = self.dataList[(indexPath as NSIndexPath).row]
        let cell: PHFeedCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath, course: course)
        
        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let course = self.dataList[(indexPath as NSIndexPath).row]
        
        let courseViewController = PHCourseRoomViewController.instantiate()
        
        courseViewController.course = course
        
        self.navigationController!.pushViewController(courseViewController, animated: true)
    }
}
