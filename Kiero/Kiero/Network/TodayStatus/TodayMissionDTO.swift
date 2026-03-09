//
//  TodayMissionDTO.swift
//  Kiero
//
//  Created by 안치욱 on 3/9/26.
//

import Foundation

struct TodayMissionDTO: Decodable {
    let name: String
    let reward: Int
}

extension TodayMissionDTO {
    func toItem() -> MissionItem {
        MissionItem(
            title: name,
            reward: reward
        )
    }
}
