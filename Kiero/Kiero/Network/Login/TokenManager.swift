//
//  TokenManager.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

import Foundation
import Security

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
        static let nameKey = "firstName"
    }

    func saveAccessToken(_ access: String) {
        save(key: Key.access, value: access)
    }

    func getAccessToken() -> String? {
        load(key: Key.access)
    }

    func saveRefreshToken(_ refresh: String) {
        save(key: Key.refresh, value: refresh)
    }

    func getRefreshToken() -> String? {
        load(key: Key.refresh)
    }

    func saveSseToken(_ sse: String) {
        save(key: Key.sse, value: sse)
    }

    func getSseToken() -> String? {
        load(key: Key.sse)
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

    func saveFirstName(_ name: String) {
        userDefaults.set(name, forKey: Key.nameKey)
    }

    func getFirstName() -> String? {
        userDefaults.string(forKey: Key.nameKey)
    }

    func saveProfile(_ profile: String) {
        userDefaults.set(profile, forKey: Key.profile)
    }

    func getProfile() -> String? {
        userDefaults.string(forKey: Key.profile)
    }

    func clearTokens() {
        delete(key: Key.access)
        delete(key: Key.refresh)
    }

    func clearUserInfo() {
        userDefaults.removeObject(forKey: Key.role)
        userDefaults.removeObject(forKey: Key.name)
        userDefaults.removeObject(forKey: Key.profile)
    }

    func clearAll() {
        clearTokens()
        clearUserInfo()
        SseStreamManager.shared.stop()
    }

    var isLoggedIn: Bool {
        getAccessToken() != nil && getRefreshToken() != nil
    }

    // MARK: - Keychain Helpers

    private func save(key: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(attributes as CFDictionary, nil)
    }

    private func load(key: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ]
        SecItemDelete(query as CFDictionary)
    }
}
