//
//  PHChatViewControllerExtensions.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 6/10/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import Alamofire

extension PHChatViewControllerExtensions where Self: PHChatViewController {
    
    func didFinishChapter() {
        
        guard self.course.lastCompletedChapterNumber < Int(self.chapter.number)! else {
            return
        }
        
        let lastCompletedChapter = self.course.lastCompletedChapter
        self.course.lastCompletedChapter = self.chapter.number
        
        self.showActivityIndicator()
        self.userInputView.completeButtonEnable(false)

        PHAPIManager.defaultManager.requestObject(.UpdateCourse(isMine: false, course: self.course), completionHandler: {[weak self] (response: Alamofire.DataResponse<PHCourse>) in
  
            self?.hideActivityIndicator()

            guard let _ = response.result.value else {
                
                self?.course.lastCompletedChapter = lastCompletedChapter
                self?.userInputView.completeButtonEnable(true)

                return
            }

            self?.course.scheduleNextDeliveryNotification()
        })
    }
}
