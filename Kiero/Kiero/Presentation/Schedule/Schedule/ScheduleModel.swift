//
//  ScheduleModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/16/26.
//

import Foundation

struct Schedule: Codable {
    let name: String
    let isRecurring: Bool
    let startTime: String
    let endTime: String
    let scheduleColor: String
    let dayOfWeek: String?
    let date: String?
    
    var dayIndices: [Int] {
        if isRecurring, let days = dayOfWeek {
            let mapping = ["MON": 0, "TUE": 1, "WED": 2, "THU": 3, "FRI": 4, "SAT": 5, "SUN": 6]
            return days.components(separatedBy: ", ").compactMap { mapping[$0] }
        } else if let dateString = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            if let date = formatter.date(from: dateString) {
                let calendar = Calendar.current
                let weekday = calendar.component(.weekday, from: date)
                let index = (weekday + 5) % 7
                return [index]
            }
        }
        return []
    }
}
