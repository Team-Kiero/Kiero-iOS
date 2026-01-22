//
//  SseDTO.swift
//  Kiero
//
//  Created by 안치욱 on 1/22/26.
//

import Foundation

struct SseEventPayload: Decodable {
    let eventType: String
    let feedItemId: Int64?
    let childId: Int64?
    let occurredAt: String?
    let metadata: SseEventMetadata?
}

struct SseEventMetadata: Decodable {
    let content: String?
    let imageUrl: String?
    let amount: Int?
}
