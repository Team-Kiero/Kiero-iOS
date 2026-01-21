//
//  TokenManager.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

import Foundation

final class TokenManager {
    static let shared = TokenManager()
    private init() {}

    private let userDefaults = UserDefaults.standard

    private enum Key {
        static let access = "access_token"
        static let refresh = "refresh_token"
        static let role = "user_role"
        static let name = "user_name"
        static let profile = "profile_url"
        static let sse = "sse_token"
    }

    func saveAccessToken(_ access: String) {
        userDefaults.set(access, forKey: Key.access)
    }

    func getAccessToken() -> String? {
        userDefaults.string(forKey: Key.access)
    }

    func saveRefreshToken(_ refresh: String) {
        userDefaults.set(refresh, forKey: Key.refresh)
    }

    func getRefreshToken() -> String? {
        userDefaults.string(forKey: Key.refresh)
    }
    
    func saveUserRole(_ role: String) {
        userDefaults.set(role, forKey: Key.role)
    }
    
    func getUserRole() -> String? {
        userDefaults.string(forKey: Key.role)
    }
    
    func saveUserName(_ name: String) {
        userDefaults.set(name, forKey: Key.name)
    }
    
    func getUserName() -> String? {
        userDefaults.string(forKey: Key.name)
    }
    
    func saveProfile(_ profile: String) {
        userDefaults.set(profile, forKey: Key.profile)
    }
    
    func getProfile() -> String? {
        userDefaults.string(forKey: Key.profile)
    }
    
    func saveSseToken(_ sse: String) {
        userDefaults.set(sse, forKey: Key.sse)
    }
    
    func getSseToken() -> String? {
        userDefaults.string(forKey: Key.sse)
    }

    func clearTokens() {
        userDefaults.removeObject(forKey: Key.access)
        userDefaults.removeObject(forKey: Key.refresh)
    }

    func clearUserInfo() {
        userDefaults.removeObject(forKey: Key.role)
        userDefaults.removeObject(forKey: Key.name)
        userDefaults.removeObject(forKey: Key.profile)
    }

    func clearAll() {
        clearTokens()
        clearUserInfo()
    }

    var isLoggedIn: Bool {
        getAccessToken() != nil && getRefreshToken() != nil
    }
}
