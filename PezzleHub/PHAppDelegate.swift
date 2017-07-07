//
//  AppDelegate.swift
//  PezzleHub
//
//  Created by Dzianis Asanovich on 2/9/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import UIKit
import GVUserDefaults
import Alamofire
import ObjectMapper
import UserNotifications

@UIApplicationMain
class PHAppDelegate: UIResponder, UIApplicationDelegate, PHApplicationConfiguration, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    fileprivate var deliveryDateTimers: [Timer] = []

    // MARK: - Lifecycle
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

//        if let options = launchOptions {
//            if let notification = options[UIApplicationLaunchOptionsKey.localNotification] as? UILocalNotification {
//                self.handleLocalNotifications(notification, showAlert: false)
//            }
//        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }

        self.setUp()
        self.setUpLocalNotifications()
        
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        application.applicationIconBadgeNumber = 0

        if PHAuthManager.isLoggedIn {
            PHUser.reloadCurrentUser({ (response) in
                
                guard let user = response.result.value else {
                    return
                }
                
                application.applicationIconBadgeNumber = (user).unreadSubscribedCoursesCount
            })
        }
        
        assert(self.initialViewController is PHInitialViewController, "Fix PSAppDelegate.initialViewController when view controller hierarchy is changed")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {

        if PHAuthManager.isLoggedIn {
            PHUser.reloadCurrentUser({ (response) in
                
                guard let user = response.result.value else {
                    return
                }
                
                application.applicationIconBadgeNumber = (user).unreadSubscribedCoursesCount
            })
        }
        
        self.tearDownDeliveryDateNotification()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if PHAuthManager.isLoggedIn {
            PHUser.reloadCurrentUser({ (response) in
                
                guard let user = response.result.value else {
                    return
                }
                
                application.applicationIconBadgeNumber = (user).unreadSubscribedCoursesCount
            })
        }

        self.setUpDeliveryDateNotification()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
    }
//    
//    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
//        
//        self.handleLocalNotifications(notification, showAlert: true)
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //self.handleLocalNotifications(notification, showAlert: true)
    }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        for (_, courseInfo) in GVUserDefaults.standard().chapterDeliveryDateInfo {
            
            let courseJSON = (courseInfo as! NSDictionary).object(forKey: "course")
            let nextDeliveryDateString = (courseInfo as! NSDictionary).object(forKey: "next_delivery_date") as! String
            
            guard let course = Mapper<PHCourse>().map(JSONObject: courseJSON) else {
                continue
            }
            guard let nextDeliveryDate = nextDeliveryDateString.toDate() else {
                continue
            }
            
            let interval = nextDeliveryDate.timeIntervalSinceNow
            
            if interval < 1.0 {
                // If already delivered
                
                self.updateCourseDeliveredChapter(course)
            }
        }

        performAfterDelay(5.0) { 
            PHUser.reloadCurrentUser { (response) in
                
                guard let user = response.result.value else {
                    completionHandler(.failed)
                    return
                }
                
                UIApplication.shared.applicationIconBadgeNumber = (user).unreadSubscribedCoursesCount
                completionHandler(.newData)
            }
        }
    }
}

extension PHAppDelegate: PHInitialViewControllerAccessor {
    
    var initialViewController: UIViewController {
        return self.window!.rootViewController!
    }
}

// MARK: - Delivery Date Notification
extension PHAppDelegate {
    
    func setUpDeliveryDateNotification() {
        
        self.deliveryDateTimers = []
        
        for (_, courseInfo) in GVUserDefaults.standard().chapterDeliveryDateInfo {
            
            let courseJSON = (courseInfo as! NSDictionary).object(forKey: "course")
            let nextDeliveryDateString = (courseInfo as! NSDictionary).object(forKey: "next_delivery_date") as! String
            
            guard let course = Mapper<PHCourse>().map(JSONObject: courseJSON) else {
                continue
            }
            guard let nextDeliveryDate = nextDeliveryDateString.toDate() else {
                continue
            }
            
            let interval = nextDeliveryDate.timeIntervalSinceNow
            
            if interval < 1.0 {
                // If already delivered
                
                self.updateCourseDeliveredChapter(course)
                
            } else {
                
                let timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(self.updateCourseDeliveredChapterTimerCallback(_:)), userInfo: course, repeats: false)
                
                self.deliveryDateTimers.append(timer)
            }
        }
    }
    
    func updateCourseDeliveredChapterTimerCallback(_ timer: Timer!) {
        
        let course = timer.userInfo as! PHCourse
        self.updateCourseDeliveredChapter(course)
    }
    
    func updateCourseDeliveredChapter(_ course: PHCourse, handler: ((Alamofire.DataResponse<PHData>) -> Void)? = nil) {
        
        let receivedChapterNumber = course.lastReceivedChapterNumber + 1
        
        course.lastReceivedChapter = String(format: "%02d", receivedChapterNumber)
        
        PHAPIManager.defaultManager.requestObject(.UpdateCourse(isMine: false, course: course), completionHandler: {[weak course] (response: Alamofire.DataResponse<PHData>) in
            
            handler?(response)
            
            guard let _ = response.result.value else {
                return
            }
            
            course?.scheduleNextDeliveryNotification()
        })
    }
    
    func tearDownDeliveryDateNotification() {
        
        for timer in self.deliveryDateTimers {
            timer.invalidate()
        }
        self.deliveryDateTimers = []
    }
}

// MARK: - Notification
extension PHAppDelegate {
    
    func setUpLocalNotifications() {
        
        let notificationSettings = UIUserNotificationSettings(types: [UIUserNotificationType.alert, UIUserNotificationType.badge, UIUserNotificationType.sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
    }
    
    func handleLocalNotifications(_ notification: UILocalNotification, showAlert: Bool) {
        
        if let userInfoDict = notification.userInfo {
            
            switch PHNotificationType(rawValue: userInfoDict[PHNotificationType.notificationTypeKey] as! String)! {
            case .NextChapterDelivery:
                if showAlert {
                    self.showNextChapterDeliveryNotification(notification)
                }
            }
        }
    }
    
    func showNextChapterDeliveryNotification(_ notification: UILocalNotification) {
        
        guard let courseJSON = notification.userInfo!["course"] as? [String: AnyObject] else {
            return
        }
        guard let course = PHCourse(JSON: courseJSON) else {
            return
        }
        
        self.updateCourseDeliveredChapter(course) { (response) in
            
            guard let loadedCourse = response.result.value else {
                return
            }

            let topViewController = self.window!.rootViewController!.getTopMostModalViewController()
            topViewController.presentAlert(notification.alertBody!, message: nil, okButtonTitle: "届いたチャプターを開く", cancelButtonTitle: "閉じる", okHandler: { (action) in
                
                let courseRoomViewController = PHCourseRoomViewController.instantiate()
                
                courseRoomViewController.course = loadedCourse as! PHCourse
                
                topViewController.presentViewControllerEmbedInNavigationController(courseRoomViewController, animated: true, completion: nil)
                
                }, cancelHandler: nil)
        }
    }
}

func getColorTheme() -> PHColorTheme {
    return PHDefaultColorTheme()
}
