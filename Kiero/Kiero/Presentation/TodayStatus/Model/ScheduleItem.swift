//
//  ScheduleItem.swift
//  Kiero
//
//  Created by 안치욱 on 3/9/26.
//

import Foundation

struct ScheduleItem: Identifiable, Hashable {
    let id: Int
    let title: String
    let startTime: String
    let endTime: String
    let imageURL: URL?
    let status: TodayStatus
    let isNowSchedule: Bool

    var timeText: String {
        "\(startTime)-\(endTime)"
    }
}
