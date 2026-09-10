//
//  AnalyticsIdentity.swift
//  Kiero
//
//  Created by Hyunseo Han on 7/28/26.
//

import CryptoKit
import Foundation

enum AnalyticsIdentity {

    static var role: AnalyticsRole {
#if KIERO_PARENT
        return .parent
#else
        return .child
#endif
    }

    static func resolveUserId() -> String? {
        guard let id = TokenManager.shared.getUserId() else { return nil }
        return "\(role.rawValue)_\(id)"
    }

    static func hashed(_ value: String) -> String {
        sha256(value.trimmingCharacters(in: .whitespacesAndNewlines).uppercased())
    }

    private static func sha256(_ value: String) -> String {
        SHA256.hash(data: Data(value.utf8))
            .map { String(format: "%02x", $0) }
            .joined()
    }
}
