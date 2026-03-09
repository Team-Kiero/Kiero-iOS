//
//  TodayScheduleDTO.swift
//  Kiero
//
//  Created by 안치욱 on 3/9/26.
//

import Foundation

struct TodayScheduleDTO: Decodable, Equatable {
    let name: String
    let startTime: String
    let endTime: String
    let imageUrl: String?
    let status: TodayStatus
    let isNowSchedule: Bool
}

extension TodayScheduleDTO {
    func toItem() -> ScheduleItem {
        ScheduleItem(
            title: name,
            startTime: startTime,
            endTime: endTime,
            imageURL: imageUrl.flatMap(URL.init(string:)),
            status: status,
            isNowSchedule: isNowSchedule
        )
    }
}
