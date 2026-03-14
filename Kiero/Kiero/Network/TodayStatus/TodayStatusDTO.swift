//
//  TodayStatusDTO.swift
//  Kiero
//
//  Created by 안치욱 on 3/6/26.
//

import Foundation

struct TodayStatusDTO: Decodable {
    let firstName: String
    let isFireLitToday: Bool
    let completeMissions: [TodayMissionDTO]
    let incompleteMissions: [TodayMissionDTO]
    let schedules: [TodayScheduleDTO]
}
