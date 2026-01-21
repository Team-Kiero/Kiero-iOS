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
