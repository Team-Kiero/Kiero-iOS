//
//  NotificationFeedDTO.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Foundation

struct FeedResponseDTO: Decodable {
    let childName: String
    let feedItems: [FeedItemDTO]
    let nextCursor: String?
}

struct FeedItemDTO: Decodable {
    let feedId: Int64?  
    let eventType: FeedEventTypeDTO
    let occurredAt: String
    let metadata: FeedMetadataDTO
}

enum FeedEventTypeDTO: String, Decodable {
    case mission = "MISSION"
    case schedule = "SCHEDULE"
    case coupon = "COUPON"
    case complete = "COMPLETE"
}

struct FeedMetadataDTO: Decodable {
    let content: String?
    let imageUrl: String?
    let amount: Int?
    let scheduleDetailId: Int64?
}

struct UnreadNotificationDTO: Decodable {
    let hasUnread: Bool
    let unreadChildIds: [Int]
}

extension FeedResponseDTO {
    func toEntity() -> FeedPage {
        .init(
            childName: childName,
            items: feedItems.map { $0.toEntity() },
            nextCursor: nextCursor
        )
    }
}

extension FeedItemDTO {
    func toEntity() -> FeedItem {
        .init(
            feedId: feedId,  
            eventType: eventType.toEntity(),
            occurredAt: occurredAt,
            metadata: metadata.toEntity()
        )
    }
}

extension FeedEventTypeDTO {
    func toEntity() -> FeedEventType {
        switch self {
        case .mission: return .mission
        case .schedule: return .schedule
        case .coupon: return .coupon
        case .complete: return .complete
        }
    }
}

extension FeedMetadataDTO {
    func toEntity() -> FeedMetadata {
        .init(
            content: content,
            imageUrl: imageUrl,
            amount: amount,
            scheduleDetailId: scheduleDetailId
        )
    }
}
