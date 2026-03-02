//
//  ScheduleDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/20/26.
//

import Foundation

struct ScheduleResponseDTO: Decodable {
    let isFireLit: Bool
    let items: [ScheduleItemDTO]
}

struct ScheduleItemDTO: Decodable {
    let scheduleId: Int
    let date: String
    let startTime: String
    let endTime: String
    let name: String
    let colorCode: String
}

struct ChildResponseDTO: Decodable {
    let childId: Int
    let childLastName: String
    let childFirstName: String
}
extension ScheduleResponseDTO {
    func toEntity() -> [Schedule] {
        return items.map {
            Schedule(
                id: $0.scheduleId,
                name: $0.name,
                isRecurring: false,
                startTime: $0.startTime,
                endTime: $0.endTime,
                scheduleColor: "SCHEDULE1",
                colorCode: $0.colorCode,
                dayOfWeek: nil,
                date: $0.date
            )
        }
    }
}

