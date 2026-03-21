//
//  NotificationBadgeCenter.swift
//  Kiero
//
//  Created by 정윤아 on 3/19/26.
//

import Combine
import Foundation

extension Notification.Name {
    static let feedItemCreated = Notification.Name("feedItemCreated")
    static let sseEventReceived = Notification.Name("sseEventReceived") 
}

final class NotificationBadgeCenter {
    static let shared = NotificationBadgeCenter()
    private init() {}

    let hasUnreadSubject = CurrentValueSubject<Bool, Never>(false)

    func setUnread(_ value: Bool) {
        hasUnreadSubject.send(value)
    }
}
