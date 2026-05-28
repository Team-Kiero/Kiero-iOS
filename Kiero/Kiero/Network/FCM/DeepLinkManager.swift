//
//  DeepLinkManager.swift
//  Kiero
//
//  Created by 정윤아 on 5/27/26.
//

import Foundation

final class DeepLinkManager {
    static let shared = DeepLinkManager()
    private init() {}

    var pendingType: String?
    var pendingTargetId: Int64?
    var hasPendingDeepLink: Bool {
        return pendingType != nil
    }

    func handle(type: String?, targetId: String?) {
        pendingType = type
        if let targetId = targetId, !targetId.isEmpty {
            pendingTargetId = Int64(targetId)
        }

        NotificationCenter.default.post(
            name: .deepLinkReceived,
            object: nil
        )
    }

    func clear() {
        pendingType = nil
        pendingTargetId = nil
    }
}

extension Notification.Name {
    static let deepLinkReceived = Notification.Name("deepLinkReceived")
}
