//
//  MissionDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation

struct MissionListResponseDTO: Decodable {
    let missionsByDate: [MissionGroupDTO]
}

struct MissionGroupDTO: Decodable {
    let dueAt: String
    let dayOfWeek: String
    let missions: [MissionItemDTO]
}

struct MissionItemDTO: Decodable {
    let id: Int
    let name: String
    let reward: Int
    let isCompleted: Bool
}
