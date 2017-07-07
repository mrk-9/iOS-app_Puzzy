//
//  PHHubCourseCellConfiguration.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 4/22/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHCourseDetailViewConfiguration: class {
    
    func configureCourseDetailView(_ detailView: PHCourseDetailView, course: PHCourse)
}

extension PHCourseDetailViewConfiguration where Self: UIViewController {
    
    func configureCourseDetailView(_ detailView: PHCourseDetailView, course: PHCourse) {
        
        detailView.setCategoryColor(course.category)
        
        detailView.imageView.setImageWithPlaceholder(course.imagePath)
        detailView.titleLabel.text = course.category.title
        detailView.descriptionLabel.text = course.title
        detailView.ratingLabel.text = "★ "+String(course.rating)
        detailView.priceLabel.text = course.price == 0 ? "無料" : String(course.price)
    }
}

protocol PHCourseCellConfiguration: PHCourseDetailViewConfiguration {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, course: PHCourse) -> PHCourseCell
}

extension PHCourseCellConfiguration where Self: UIViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, course: PHCourse) -> PHCourseCell {
        
        let cell = tableView.dequeueReusableCell(PHCourseCell.self, indexPath: indexPath)
        
        self.configureCourseDetailView(cell.detailView, course: course)
        
        return cell
    }
}
