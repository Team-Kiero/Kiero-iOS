//
//  MissionItem.swift
//  Kiero
//
//  Created by 안치욱 on 3/9/26.
//

import Foundation

struct MissionItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let reward: Int

    var rewardText: String {
        "\(reward)개"
    }
}
