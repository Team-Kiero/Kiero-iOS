//
//  ScheduleDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/20/26.
//

import Foundation

struct ScheduleResponseDTO: Decodable {
    let isFireLit: Bool
    let recurringSchedules: [RecurringScheduleDTO]
    let normalSchedules: [NormalScheduleDTO]
}

struct RecurringScheduleDTO: Decodable {
    let startTime: String
    let endTime: String
    let name: String
    let colorCode: String
    let dayOfWeek: String
}

struct NormalScheduleDTO: Decodable {
    let startTime: String
    let endTime: String
    let name: String
    let colorCode: String
    let date: String
}

struct ChildResponseDTO: Decodable {
    let childId: Int
    let childLastName: String
    let childFirstName: String
}

extension ScheduleResponseDTO {
    func toEntity() -> [Schedule] {
        let recurring = recurringSchedules.map {
            Schedule(
                name: $0.name,
                isRecurring: true,
                startTime: $0.startTime,
                endTime: $0.endTime,
                scheduleColor: "SCHEDULE1",
                colorCode: $0.colorCode,
                dayOfWeek: $0.dayOfWeek,
                date: nil
            )
        }
        
        let normal = normalSchedules.map {
            Schedule(
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
        
        return recurring + normal
    }
}
