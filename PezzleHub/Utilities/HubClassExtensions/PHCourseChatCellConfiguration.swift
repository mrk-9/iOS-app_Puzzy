//
//  PHFeedCellConfiguration.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/2/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

protocol PHCourseChatCellConfiguration: class {
    
    var isMyCourse: Bool { set get }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, course: PHCourse) -> PHFeedCell
}

extension PHCourseChatCellConfiguration where Self: UIViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath, course: PHCourse) -> PHFeedCell {
        
        let cell = tableView.dequeueReusableCell(PHFeedCell.self, indexPath: indexPath)
        
        cell.setCategoryColor(course.category)
        
        cell.titleLabel.text = course.title
        cell.descriptionLabel.text = ""
        
//        self.loadChapters(PHCourse) { ([PHChapter]) in
//            <#code#>
//        }
        
        self.loadChapters(course) {(chapters) in
            
//            guard let cell = cell else {
//                return
//            }
//            guard let course = course else {
//                return
//            }
//            guard chapters.count > 0 else {
//                return
//            }
            
            var chapterIndex = (course.lastCompletedChapterNumber - 1)
            
            if chapterIndex >= chapters.count {
                
                chapterIndex = chapters.count - 1
            }
            if chapterIndex < 0 {
                
                chapterIndex = 0
            }
            
            let theChapter = chapters[chapterIndex]
            cell.descriptionLabel.text = "第"+theChapter.number+"回 "+theChapter.title
        }
        
        cell.photoView.setImageWithPlaceholder(course.imagePath)

        if let _ = course.lastCompletedChapter {
            
            cell.chapterProgress.isHidden = false
            cell.chapterProgress.progress = Float(course.lastCompletedChapterNumber) / Float(course.chaptersCount)
            
        } else {
            
            cell.chapterProgress.isHidden = true
        }

        self.configureCellAppearance(cell, course: course)

        return cell
    }
    
    func loadChapters(_ course: PHCourse, handler: @escaping ([PHChapter]) -> Void) {
        
        let router = PHRouter.GetChapters(isMine: self.isMyCourse, courseID: course.id)
        let limit = course.lastReceivedChapterNumber + 1
        
        PHAPIManager.defaultManager.requestArray(router, offset: 0, limit: limit) { (response: Alamofire.DataResponse<[PHChapter]>) in
            
            guard let results = response.result.value else {
                return
            }
            handler(results)
        }
    }
    
    func configureCellAppearance(_ cell: PHFeedCell, course: PHCourse) {
        
        let colorTheme = getColorTheme()
        let categoryColor = course.category.color
        let progressColor = colorTheme.progressColor
        
        if course.lastCompletedChapterNumber < course.lastReceivedChapterNumber {
            
            // 未読チャプターのあるもの
            cell.contentView.backgroundColor = categoryColor
            cell.titleLabel.textColor = UIColor.white
            cell.descriptionLabel.textColor = UIColor.white
            cell.chapterProgress.progressTintColor = UIColor.white
            cell.chapterProgress.trackTintColor = progressColor
            cell.deliveryDateLabel.isHidden = true
            cell.finishReadingBadge.isHidden = true
            
        } else {
            
            // 未読チャプターのないもの
            cell.contentView.backgroundColor = UIColor.clear
            cell.titleLabel.textColor = categoryColor
            cell.descriptionLabel.textColor = categoryColor
            cell.chapterProgress.progressTintColor = categoryColor
            cell.chapterProgress.trackTintColor = progressColor
            
            if course.lastCompletedChapterNumber == course.chaptersCount {
                
                cell.deliveryDateLabel.isHidden = true
                cell.finishReadingBadge.isHidden = false
                
            } else {
                
                cell.deliveryDateLabel.backgroundColor = categoryColor
                cell.finishReadingBadge.isHidden = true
                
                if let nextDeliveryDate = course.nextDeliveryDate {
                    
                    cell.deliveryDateLabel.isHidden = false
                    cell.deliveryDateLabel.text = nextDeliveryDate.dateTimeAfterUsingDefaultTimezone()
                    
                } else {
                    
                    cell.deliveryDateLabel.isHidden = true
                }
            }
        }
    }
}
