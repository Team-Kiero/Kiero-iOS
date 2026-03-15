//
//  ScheduleDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/20/26.
//

import Foundation
import UIKit

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
    let scheduleStatus: String?
}

struct ChildResponseDTO: Decodable {
    let childId: Int
    let childLastName: String
    let childFirstName: String
}

struct DeleteScheduleRequestDTO: Encodable {
    let isIncludeFollowing: Bool
}

struct EditScheduleRequestDTO: Encodable {
    let name: String
    let isRecurring: Bool
    let startTime: String
    let endTime: String
    let scheduleColor: String
    let dayOfWeek: String?
    let dates: String?
    let isIncludeFollowing: Bool?
}

extension ScheduleResponseDTO {
    func toEntity() -> [Schedule] {
        return items.map {
            let isRecurring = !$0.dayOfWeek.isEmpty
            let dayOfWeekString = $0.dayOfWeek.map { koreanDay($0) }.joined(separator: ", ")
            let scheduleColor = scheduleColorFromHex($0.colorCode)
            
            return Schedule(
                id: $0.scheduleId,
                name: $0.name,
                isRecurring: isRecurring,
                startTime: $0.startTime,
                endTime: $0.endTime,
                scheduleColor: scheduleColor,
                colorCode: $0.colorCode,
                dayOfWeek: dayOfWeekString.isEmpty ? nil : dayOfWeekString,
                date: $0.date,
                scheduleStatus: $0.scheduleStatus
            )
        }
    }
    
    private func scheduleColorFromHex(_ hex: String) -> String {
        let mapping: [String: String] = [
            UIColor.schedule1.toHexString(): "SCHEDULE1",
            UIColor.schedule2.toHexString(): "SCHEDULE2",
            UIColor.schedule3.toHexString(): "SCHEDULE3",
            UIColor.schedule4.toHexString(): "SCHEDULE4",
            UIColor.schedule5.toHexString(): "SCHEDULE5"
        ]
        return mapping[hex.uppercased()] ?? "SCHEDULE1"
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
