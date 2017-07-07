//
//  PHCourseListController.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

/// ViewController with listed courses, for Perzzle Hub. Selecting a cell transits to PHCourseViewController. 
/// For Perzzle Feed, use PHCourseChatListController.
class PHCourseListController: PHCourseListAbstractController, PHCourseCellConfiguration {

    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.tableView.registerCell(PHCourseCell.self)
        self.tableView.rowHeight = PHCourseCell.defaultRowHeight
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath as NSIndexPath).section == 1 {
            return self.tableView(tableView, loadingCellForRowAtIndexPath: indexPath)
        }

        let course = self.dataList[(indexPath as NSIndexPath).row]
        let cell: PHCourseCell = self.tableView(tableView, cellForRowAtIndexPath: indexPath, course: course)
        
        return cell
    }

    // MARK: - UITableViewDelegate    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        
        let courseViewController = PHCourseViewController.instantiate()
        let course = self.dataList[(indexPath as NSIndexPath).row]
        
        switch self.courseListRouter! {
        case PHRouter.GetCourses(let isMine, _):
            courseViewController.isMyCourse = isMine
            
        default:
            courseViewController.isMyCourse = false
        }
        courseViewController.course = course
        
        self.navigationController!.pushViewController(courseViewController, animated: true)
    }
}
