//
//  MissionModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/16/26.
//

import Foundation

struct Mission: Codable {
    let name: String
    let reward: Int
    let dueAt: String
}
