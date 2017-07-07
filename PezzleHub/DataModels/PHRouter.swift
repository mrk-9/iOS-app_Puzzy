//
//  PHRouter.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/4/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import Alamofire

struct PHRouterPagingWrapper: URLRequestConvertible {
    
    let router: PHRouter
    let offset: Int
    let limit: Int
    
    func asURLRequest() throws -> URLRequest {
        
        assert(self.router.method == .get, "Given router does not support paging")
        
        let mutableRequest = self.router.urlRequest
        let parameters = [
            "offset": self.offset,
            "limit": self.limit,
        ]
        
        return try URLEncoding.default.encode(mutableRequest!, with: parameters) as URLRequest
//        return Alamofire.ParameterEncoding.URLEncodedInURL.encode(mutableRequest, parameters: parameters).0
    }
}

// https://github.com/Alamofire/Alamofire#crud--authorization
enum PHRouter: URLRequestConvertible {
    static let baseURLString = perzzleAPIDomain
    
    case Login(username: String, password: String)
    case SignUp(username: String, password: String)
    case RefreshToken
    case ResetPassword(email: String)
    case GetMe
    case GetMySubscribedCourses
    case GetCourses(isMine: Bool, parameters: [String: AnyObject]?) // Parameter: "is_featured", "category_id", "is_published", "inname"
    case GetCourse(isMine: Bool, courseID: Int)
    case GetUserCourses(userEncryptedID: String)
    case GetChapters(isMine: Bool, courseID: Int)
    case GetPieces(isMine: Bool, chapterID: Int)
    case GetFeaturedStudioUser
    case GetCategories
    case GetCourseComments(courseID: Int)
    case PostCourseComments(courseID: Int, text: String)
    case UpdateCourse(isMine: Bool, course: PHCourse)   // Parameters: "last_received_chapter", "last_completed_chapter"
    case SubscribeCourse(courseID: Int)
    case UnsubscribeCourse(courseID: Int)
    case UpdateProfile(parameters: [String: AnyObject])
    case UploadProfileImage

    var method: HTTPMethod {
        switch self {
        case .Login, .SignUp, .SubscribeCourse, .RefreshToken, .ResetPassword, .PostCourseComments, .UploadProfileImage:
            return .post
            
        case .UpdateCourse:
            return .put
            
        case .UpdateProfile:
            return .patch
            
        case .UnsubscribeCourse:
            return .delete
            
        case .GetMe, .GetMySubscribedCourses, .GetCourses, .GetCourse, .GetUserCourses, .GetChapters, .GetPieces, .GetFeaturedStudioUser, .GetCategories, .GetCourseComments:
            return .get
        }
    }
    
    var path: String {
        switch self {
        case .Login:
            return "/auth/login"
            
        case .SignUp:
            return "/auth/signup"
            
        case .RefreshToken:
            return "/auth/refresh_token"
            
        case .ResetPassword:
            return "/password/require_reset"
            
        case .GetMe:
            return "/me"
            
        case .GetMySubscribedCourses:
            return "/me/subscribed_courses"
            
        case .GetCourses(let isMine, _):
            return (isMine ? "/me" : "") + "/courses"
            
        case .GetCourse(let isMine, let courseID):
            return (isMine ? "/me" : "") + "/courses/" + String(courseID)
            
        case .GetUserCourses(let userEncryptedID):
            return "/users/"+String(userEncryptedID)+"/courses"
            
        case .GetChapters(let isMine, let courseID):
            return (isMine ? "/me" : "") + "/courses/"+String(courseID)+"/chapters"
            
        case .GetPieces(let isMine, let chapterID):
            return (isMine ? "/me" : "") + "/chapters/"+String(chapterID)+"/pieces"
            
        case .GetFeaturedStudioUser:
            return "/featured_studio_users"
            
        case .GetCategories:
            return "/categories"
            
        case .GetCourseComments(let courseID):
            return "/courses/"+String(courseID)+"/comments"
            
        case .PostCourseComments(let courseID, _):
            return "/courses/"+String(courseID)+"/comments"
            
        case .UpdateCourse(let isMine, let course):
            return isMine ? "/me/courses/"+String(course.id) : "/me/subscribed_courses/"+String(course.id)
            
        case .SubscribeCourse(_):
            return "/me/subscribed_courses"
            
        case .UnsubscribeCourse(let courseID):
            return "/me/subscribed_courses/"+String(courseID)
            
        case .UploadProfileImage:
            return "/me/upload"
            
        case .UpdateProfile(_):
            return "/me"
        }
    }
    
    var shouldAuthenticate: Bool {
        switch self {
        case .Login, .SignUp, .ResetPassword, .RefreshToken:
            return false
            
        default:
            return true
        }
    }
    
    var isCourseRouter: Bool {
        switch self {
        case .GetMySubscribedCourses, .GetCourses, .GetUserCourses:
            return true
            
        default:
            return false
        }
    }

    func asURLRequest() throws -> URLRequest {
        let url = try PHRouter.baseURLString.asURL()
        
        let mutableURLRequest = NSMutableURLRequest(url: url.appendingPathComponent(path))
        
        
        mutableURLRequest.httpMethod = method.rawValue
        
        if shouldAuthenticate {
            let token = PHAuthManager.getToken()
            if token != nil {
                let tokenStr = "Token "+token!
                mutableURLRequest.setValue(tokenStr, forHTTPHeaderField: "Authorization")
            }
        }
        
        switch self {
        case .Login(let username, let password):
            
            let isStudio = Bundle.main.bundleIdentifier?.range(of: "studio", options: .caseInsensitive, range: nil, locale: nil) != nil
            let parameters: [String: AnyObject] = [ "email_or_studio_unique_name": username as AnyObject, "password": password as AnyObject, "rt_mode": true as AnyObject, "is_studio": isStudio as AnyObject ]
            
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: parameters) as URLRequest
            
        case .SignUp(let username, let password):
            
            let parameters: [String: AnyObject] = [ "email": username as AnyObject, "password": password as AnyObject, "rt_mode": true as AnyObject ]
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: parameters) as URLRequest
            
        case .RefreshToken:
            
            guard let token = PHAuthManager.getToken() else {
                return mutableURLRequest as URLRequest
            }
            guard let refreshToken = PHAuthManager.getRefreshToken() else {
                return mutableURLRequest as URLRequest
            }
            
            let parameters: [String: AnyObject] = [ "token": token as AnyObject, "refresh_token": refreshToken as AnyObject ]
            
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
            
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: parameters) as URLRequest
            
        case .GetCourses(_, let parameters):
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: parameters) as URLRequest
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
        case .UpdateCourse(_, let course):
            let parameters = course.toJSON()
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: parameters as [String : AnyObject]?) as URLRequest
            
        case .SubscribeCourse(let courseID):
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: ["course_id": courseID as AnyObject])
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: ["course_id": courseID as AnyObject]) as URLRequest
            
        case .UnsubscribeCourse(let courseID):
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: ["course_id": courseID as AnyObject])
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: ["course_id": courseID as AnyObject]) as URLRequest
            
        case .PostCourseComments(_, let text):
            
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: ["content": text as AnyObject])
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: ["content": text as AnyObject]) as URLRequest
            
        case .UpdateProfile(let parameters):
//            return try URLEncoding.default.encode(mutableURLRequest as! URLRequestConvertible, with: parameters)
            return try createURLRequestWithParameter(request: mutableURLRequest as URLRequest, parameters: parameters) as URLRequest
            
        default:
            return mutableURLRequest as URLRequest
        }
        
//        return urlRequest!
    }
    
    func createURLRequestWithParameter(request: URLRequest, parameters: [String: AnyObject]?) throws -> NSURLRequest {
        
        guard let parameters = parameters else {
            return request as NSURLRequest
        }
        guard parameters.isEmpty == false else {
            return request as NSURLRequest
        }
        
        switch Alamofire.HTTPMethod(rawValue: method.rawValue)! {
        case .get:
//            encoding = Alamofire.URLEncoding as! ParameterEncoding
            return try URLEncoding.default.encode(request, with: parameters) as NSURLRequest
        case .post, .patch, .put, .delete:
//            encoding = Alamofire.JSONEncoding as! ParameterEncoding
            return try Alamofire.JSONEncoding.default.encode(request, with: parameters) as NSURLRequest
//            return try JSONEncoding.default.encode(request as! URLRequestConvertible, with: parameters) as NSURLRequest
            
        default:
            fatalError("Implement encoding")
        }
        
//        return try encoding.encode(request as! URLRequestConvertible, with: parameters) as NSURLRequest
    }

}
