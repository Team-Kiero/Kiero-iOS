//
//  NotificationFeedModels.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Foundation

struct FeedPage {
    let childName: String
    let items: [FeedItem]
    let nextCursor: String?
}

struct FeedItem: Hashable {
    let eventType: FeedEventType
    let occurredAt: String
    let metadata: FeedMetadata
}

enum FeedEventType: String {
    case mission
    case schedule
    case coupon
    case complete
}

struct FeedMetadata: Hashable {
    let content: String?
    let imageUrl: String?
    let amount: Int?
}
