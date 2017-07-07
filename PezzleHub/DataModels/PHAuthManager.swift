//
//  PHAuthManager.swift
//  PezzleHub
//
//  Created by Yamazaki Mitsuyoshi on 5/4/16.
//  Copyright © 2016 PersonalStock. All rights reserved.
//

import Foundation
import SSKeychain
import GVUserDefaults

struct PHAuthManager {
    
    fileprivate static let tokenKey = "token"
    fileprivate static let refreshTokenKey = "refresh_token"
    
    static var isLoggedIn: Bool {
        
        let tokenExists = self.getToken() != nil
        let refreshTokenExists = self.getRefreshToken() != nil
        
        return tokenExists && refreshTokenExists
    }
    
    // MARK: - Token
    static func saveToken(_ token: String) {
        
//        SSKeychain.setPassword(token, forService: perzzleServiceName, account: self.tokenKey)
        UserDefaults.standard.setValue(token, forKey: self.tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    static func getToken() -> String? {
        
        return UserDefaults.standard.value(forKey: self.tokenKey) as! String?
//        return SSKeychain.password(forService: perzzleServiceName, account: self.tokenKey)
    }
    
    // MARK: - Refresh Token
    static func saveRefreshToken(_ refreshToken: String) {
        UserDefaults.standard.setValue(refreshToken, forKey: self.refreshTokenKey)
        UserDefaults.standard.synchronize()
//        SSKeychain.setPassword(refreshToken, forService: perzzleServiceName, account: self.refreshTokenKey)
    }
    
    static func getRefreshToken() -> String? {
        
        return UserDefaults.standard.value(forKey: self.refreshTokenKey) as! String?
//        return SSKeychain.password(forService: perzzleServiceName, account: self.refreshTokenKey)
    }
    
    // MARK: -
    static func deleteTokens() {
        
        UIApplication.shared.applicationIconBadgeNumber = 0
        PHUser.currentUser = nil
        GVUserDefaults.standard().resetUserDefaults()

        UserDefaults.standard.setValue("", forKey: self.tokenKey)
        UserDefaults.standard.setValue("", forKey: self.refreshTokenKey)
        UserDefaults.standard.synchronize()
        SSKeychain.deletePassword(forService: perzzleServiceName, account: self.tokenKey)
        SSKeychain.deletePassword(forService: perzzleServiceName, account: self.refreshTokenKey)
    }
}
