//
//  PHCourseChatCellConfiguration.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHCourseChatCellConfiguration: class {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, course: PHCourse) -> PHFeedCell
}

extension PHCourseChatCellConfiguration where Self: UIViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, course: PHCourse) -> PHFeedCell {
        
        let cell = tableView.dequeueReusableCell(PHFeedCell.self, indexPath: indexPath)
        
        cell.setCategoryColor(course.category)
        
        cell.titleLabel.text = course.title
        cell.photoView.setImageWithPlaceholder(course.imagePath)
        
        cell.chapterProgress.isHidden = true
        
        let categoryColor = course.category.color
        
        cell.contentView.backgroundColor = categoryColor
        cell.titleLabel.textColor = UIColor.white
        cell.deliveryDateLabel.isHidden = true
        cell.finishReadingBadge.isHidden = true
        
        return cell
    }
}
