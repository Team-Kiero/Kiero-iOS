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
    }

    func saveAccessToken(_ access: String) {
        userDefaults.set(access, forKey: Key.access)
    }

    func getAccessToken() -> String? {
        userDefaults.string(forKey: Key.access)
    }

    func clear() {
        userDefaults.removeObject(forKey: Key.access)
    }

    var isLoggedIn: Bool {
        getAccessToken() != nil
    }
}
