//
//  TodayScheduleDTO.swift
//  Kiero
//
//  Created by 안치욱 on 3/9/26.
//

import Foundation

struct TodayScheduleDTO: Decodable {
    let scheduleDetailId: Int
    let name: String
    let startTime: String
    let endTime: String
    let status: TodayStatus
    let isOngoing: Bool
}

struct ScheduleImageDTO: Decodable {
    let imageUrl: String
}

extension TodayScheduleDTO {
    func toItem() -> ScheduleItem {
        ScheduleItem(
            id: scheduleDetailId,
            title: name,
            startTime: String(startTime.prefix(5)),
            endTime: String(endTime.prefix(5)),
            status: status,
            isNowSchedule: isOngoing
        )
    }
}
