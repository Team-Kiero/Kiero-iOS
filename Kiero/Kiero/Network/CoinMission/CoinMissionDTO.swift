//
//  CoinMissionService.swift
//  Kiero
//
//  Created by 정윤아 on 1/22/26.
//

import Foundation

struct MissionCompleteResponseDTO: Decodable {
    let id: Int64
    let name: String
    let reward: Int
    let dueAt: String       
    let isCompleted: Bool
}
