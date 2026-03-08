//
//  TodayStatusDTO.swift
//  Kiero
//
//  Created by 안치욱 on 3/6/26.
//


struct TodayStatusDTO: Decodable {
    let isFireLitToday: Bool
    let completeMissions: [MissionDTO]
    let incompleteMissions: [MissionDTO]
    let schedules: [TodayScheduleDTO]
}

struct MissionDTO: Decodable, Identifiable {
    let name: String
    let reward: Int
    
    var id: String {
        "\(name)-\(reward)"
    }
}

struct TodayScheduleDTO: Decodable, Identifiable {
    let name: String
    let startTime: String
    let endTime: String
    let imageUrl: String?
    let status: TodayStatus
    let isNowSchedule: Bool

    var id: String {
        "\(name)-\(startTime)-\(endTime)"
    }
}
