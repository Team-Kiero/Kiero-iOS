//
//  AuthTokenStorage.swift
//  Kiero
//
//  Created by 안치욱 on 5/2/26.
//

import Foundation

protocol AuthTokenStorageType {
    
    var accessToken: String? { get }
    var userRole: String? { get }
    var userName: String? { get }
    var profile: String? { get }
    
    func saveAccessToken(_ token: String)
    func saveRefreshToken(_ token: String)
    func saveUserRole(_ role: String)
    func saveUserName(_ name: String)
    func saveFirstName(_ name: String)
    func saveProfile(_ imageURL: String)
    func clearAll()
}

final class AuthTokenStorage: AuthTokenStorageType {
    
    var accessToken: String? {
        TokenManager.shared.getAccessToken()
    }
    
    var userRole: String? {
        TokenManager.shared.getUserRole()
    }
    
    var userName: String? {
        TokenManager.shared.getUserName()
    }
    
    var profile: String? {
        TokenManager.shared.getProfile()
    }
    
    func saveAccessToken(_ token: String) {
        TokenManager.shared.saveAccessToken(token)
    }
    
    func saveRefreshToken(_ token: String) {
        TokenManager.shared.saveRefreshToken(token)
    }
    
    func saveUserRole(_ role: String) {
        TokenManager.shared.saveUserRole(role)
    }
    
    func saveUserName(_ name: String) {
        TokenManager.shared.saveUserName(name)
    }
    
    func saveFirstName(_ name: String) {
        TokenManager.shared.saveFirstName(name)
    }
    
    func saveProfile(_ imageURL: String) {
        TokenManager.shared.saveProfile(imageURL)
    }
    
    func clearAll() {
        TokenManager.shared.clearAll()
    }
}
