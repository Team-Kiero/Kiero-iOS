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
    let dayOfWeek: [String]
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
            let isRecurring = !$0.dayOfWeek.isEmpty
            let dayOfWeekString = $0.dayOfWeek.map { koreanDay($0) }.joined(separator: ", ")
            
            return Schedule(
                id: $0.scheduleId,
                name: $0.name,
                isRecurring: isRecurring,
                startTime: $0.startTime,
                endTime: $0.endTime,
                scheduleColor: "SCHEDULE1",
                colorCode: $0.colorCode,
                dayOfWeek: dayOfWeekString.isEmpty ? nil : dayOfWeekString,
                date: $0.date
            )
        }
    }
    
    private func koreanDay(_ day: String) -> String {
        switch day {
        case "MON": return "월"
        case "TUE": return "화"
        case "WED": return "수"
        case "THU": return "목"
        case "FRI": return "금"
        case "SAT": return "토"
        case "SUN": return "일"
        default: return day
        }
    }
}
