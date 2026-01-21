//
//  AIMissionDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation

struct MissionSuggestionRequestDTO: Encodable {
    let noticeText: String
}

struct MissionSuggestionResponseDTO: Decodable {
    let suggestedMissions: [SuggestedMissionDTO]
}

struct SuggestedMissionDTO: Decodable {
    let name: String
    let dueAt: String
    let reward: Int
}

struct MissionBulkCreateRequestDTO: Encodable {
    let missions: [MissionBulkItemDTO]
}

struct MissionBulkItemDTO: Encodable {
    let name: String
    let reward: Int
    let dueAt: String
}

struct MissionBulkCreateResponseDTO: Decodable {
    let id: Int
    let name: String
    let reward: Int
    let dueAt: String
    let isCompleted: Bool
}
