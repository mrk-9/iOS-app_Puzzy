//
//  PHAPIManager.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 3/31/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import SwiftyJSON

typealias PHAPIJSONHandler = (Alamofire.DataResponse<Any>) -> Void
//typealias PHAPIObjectHandler<T> = (Alamofire.DataResponse<T, NSError>) -> Void    // Want to do something like this but typealias doesn't support generics. Any idea?
//typealias PHAPIArrayHandler<T> = (Alamofire.DataResponse<[T], NSError>) -> Void

class PHAPIError: Mappable {
    
    enum StatusCode: Int {
        case unknown        = 1000
        case invalidToken   = 100
        case invalidRefreshToken    = 101
    }
    
    var statusCode: StatusCode!
    
    // MARK: - Mappable
    required init(map: Map) {

        self.mapping(map: map)
    }
    
    func mapping(map: Map) {

        self.statusCode <- map["error_code"]
        
        if self.statusCode == nil {
            self.statusCode = StatusCode.unknown
        }        
    }
}

class PHAPIManager {

    static let defaultManager = PHAPIManager()

    func requestJSON(_ router: PHRouter, retryCount: Int = 1, completionHandler: ((Alamofire.DataResponse<Any>) -> Void)? = nil) -> Void {
        
        Alamofire.request(router).validate().responseJSON(completionHandler: { (response: Alamofire.DataResponse<Any>) in
            
            if let error = self.handleAPIError(response) {
                if error.statusCode == PHAPIError.StatusCode.invalidToken {
                    if retryCount > 0 {
                        
                        self.refreshToken({ (refreshTokenResponse) in
                            
                            if refreshTokenResponse.result.isSuccess {
                                self.requestJSON(router, retryCount: retryCount - 1, completionHandler: completionHandler)
                                return
                            }
                            
                            completionHandler?(response)
                        })
                        return
                    }
                }
                
            }
            completionHandler?(response)
        })
    }

    func requestObject<T: PHData>(_ router: PHRouter, retryCount: Int = 1, completionHandler: ((Alamofire.DataResponse<T>) -> Void)? = nil) -> Void {
        
        assert(T.self != PHPiece.self, "PHPiece cannot be parsed using this method. See PHChatViewController.loadData()")

        Alamofire.request(router).validate().responseObject(completionHandler: { (response: Alamofire.DataResponse<T>) in
            
            if let error = self.handleAPIError(response) {
                if error.statusCode == PHAPIError.StatusCode.invalidToken {
                    if retryCount > 0 {
                        self.refreshToken({ (refreshTokenResponse) in
                            
                            if refreshTokenResponse.result.isSuccess {
                                self.requestObject(router, retryCount: retryCount - 1, completionHandler: completionHandler)
                                return
                            }
                            
                            completionHandler?(response)
                        })
                        return
                    }
                }
                
            }
            completionHandler?(response)
        })
    }

    func requestArray<T: PHData>(_ router: PHRouter, retryCount: Int = 1, offset: Int, limit: Int = 20, completionHandler: ((Alamofire.DataResponse<[T]>) -> Void)? = nil) -> Void {
        
        assert(T.self != PHPiece.self, "PHPiece cannot be parsed using this method. See PHChatViewController.loadData()")
        
        let wrappedRouter = PHRouterPagingWrapper(router: router, offset: offset, limit: limit)
        Alamofire.request(wrappedRouter).validate().responseArray(queue: nil, keyPath: "results", context: nil) { (response: Alamofire.DataResponse<[T]>) in
            if let error = self.handleAPIError(response) {
                if error.statusCode == PHAPIError.StatusCode.invalidToken {
                    if retryCount > 0 {
                        self.refreshToken({ (refreshTokenResponse) in
                            
                            if refreshTokenResponse.result.isSuccess {
                                self.requestArray(router, retryCount: retryCount - 1, offset: offset, limit: limit, completionHandler: completionHandler)
                                return
                            }
                            
                            completionHandler?(response)
                        })
                        return
                    }
                }
                
            }
            completionHandler?(response)
        }
        
    }
    
    func uploadMultipartFormData(_ router: PHRouter, imageData: Data, retryCount: Int = 1, completionHandler: ((Alamofire.DataResponse<Any>) -> Void)? = nil) {
        
        Alamofire.upload(multipartFormData: { (data) in
            data.append(imageData, withName: "file", fileName: "profileimage.png", mimeType: "image/png")
            }, with: router) { (result) in
                
                switch result {
                case .success(let upload, _, _):
                    upload.validate().responseJSON(completionHandler: { (response) in
                        if let error = self.handleAPIError(response) {
                            if error.statusCode == PHAPIError.StatusCode.invalidToken {
                                if retryCount > 0 {
                                    self.refreshToken({ (refreshTokenResponse) in
                                        if refreshTokenResponse.result.isSuccess {
                                            self.uploadMultipartFormData(router, imageData: imageData, retryCount: retryCount - 1, completionHandler: completionHandler)
                                            return
                                        }
                                        completionHandler?(response)
                                    })
                                    
                                    return
                                }
                            }
                        }
                        completionHandler?(response)
                    })
                    break
                case .failure(let error):
                    print(error)
                    break
                }

        }
        
    }
    
    fileprivate func handleAPIError<T>(_ response: Alamofire.DataResponse<T>) -> PHAPIError? {
        
        guard response.result.isFailure else {
            return nil
        }
        
        debugPrint(response)

        guard let data = response.data else {
            return nil
        }
        guard let responseDataString = String(data: data, encoding: String.Encoding.utf8) else {
            return nil
        }
        debugPrint(responseDataString)

        guard let apiError = Mapper<PHAPIError>().map(JSONString: responseDataString) else {
            return nil
        }

        switch apiError.statusCode as PHAPIError.StatusCode {
        case PHAPIError.StatusCode.invalidRefreshToken:
            PHAuthManager.deleteTokens()
            
            let appDelegte = UIApplication.shared.delegate as! PHInitialViewControllerAccessor
            appDelegte.revealInitialViewController(self)
            
        case PHAPIError.StatusCode.unknown, PHAPIError.StatusCode.invalidToken:
            break
        }
        
        return apiError
    }
}

// MARK: - Authentication
extension PHAPIManager {
    
    fileprivate func saveTokens(_ response: Alamofire.DataResponse<Any>) {
        
        guard response.result.isSuccess else {
            return
        }
        guard let result = response.result.value else {
            return
        }
        
        let JSONData = JSON(result)
        
        if let token = JSONData["token"].string {
            PHAuthManager.saveToken(token)
        }
        if let refreshToken = JSONData["refresh_token"].string {
            PHAuthManager.saveRefreshToken(refreshToken)
        }
    }
    
    func login(_ username: String, password: String, completionHandler: PHAPIJSONHandler? = nil) -> Void {
        
        self.requestJSON(.Login(username: username, password: password), completionHandler: { (response) in
            
            self.saveTokens(response)
            completionHandler?(response)
        })
    }
    
    func signUp(_ username: String, password: String, completionHandler: PHAPIJSONHandler? = nil) -> Void {
        
        self.requestJSON(.SignUp(username: username, password: password), completionHandler: { (response) in
            
            self.saveTokens(response)
            completionHandler?(response)
        })
    }
    
    func refreshToken(_ completionHandler: PHAPIJSONHandler? = nil) -> Void {
        
        self.requestJSON(.RefreshToken, retryCount: 0, completionHandler: { (response) in

            if response.result.isFailure {
                
                PHAuthManager.deleteTokens()
                
                let appDelegte = UIApplication.shared.delegate as! PHInitialViewControllerAccessor
                appDelegte.revealInitialViewController(self)
                
            } else {
                
                self.saveTokens(response)
            }
            
            completionHandler?(response)
        })
    }
    
    func uploadImage(_ image: UIImage, completionHandler: PHAPIJSONHandler? = nil) {
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            return
        }
        
        self.uploadMultipartFormData(.UploadProfileImage, imageData: imageData, completionHandler: { (response) in
            
            completionHandler?(response)
        })
    }
}
