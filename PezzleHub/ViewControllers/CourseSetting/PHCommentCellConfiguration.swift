//
//  PHCourseReviewCellConfiguration.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit

protocol PHCommentCellConfiguration: class {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, comment: PHComment) -> PHCommentCell
}

extension PHCommentCellConfiguration where Self: UIViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, comment: PHComment) -> PHCommentCell {
        
        let cell = tableView.dequeueReusableCell(PHCommentCell.self, indexPath: indexPath)
        
        cell.commentLabel.text = comment.comment
        cell.photoImageView.setImageWithPlaceholder(comment.author.imagePath)
        cell.dateLabel.text = comment.date.dateTimeAgoUsingDefaultTimezone()
        
        return cell
    }
}
