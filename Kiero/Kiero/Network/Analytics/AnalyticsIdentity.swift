//
//  AnalyticsIdentity.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import CryptoKit
import Foundation
import Security

enum AnalyticsIdentity {

    private static let deviceIdKeychainAccount = "analytics_device_id"

    static var role: String {
#if KIERO_PARENT
        return "parent"
#else
        return "child"
#endif
    }

    static func resolveUserId() -> String? {
#if KIERO_PARENT
        guard let email = TokenManager.shared.getEmail(), !email.isEmpty else { return nil }
        return sha256(email)
#else
        return deviceScopedId()
#endif
    }

    private static func deviceScopedId() -> String {
        if let saved = loadKeychain(account: deviceIdKeychainAccount) {
            return saved
        }

        let generated = UUID().uuidString
        saveKeychain(account: deviceIdKeychainAccount, value: generated)
        return generated
    }

    static func hashed(_ value: String) -> String {
        sha256(value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased())
    }

    private static func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }

    // MARK: - Keychain

    private static func saveKeychain(account: String, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account
        ]

        SecItemDelete(query as CFDictionary)

        let attributes: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock
        ]

        SecItemAdd(attributes as CFDictionary, nil)
    }

    private static func loadKeychain(account: String) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)

        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
