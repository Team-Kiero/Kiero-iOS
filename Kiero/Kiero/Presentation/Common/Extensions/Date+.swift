//
//  Date+.swift
//  Kiero
//
//  Created by 신혜연 on 1/17/26.
//

import Foundation

extension Date {
    var daysOfWeek: [Date] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: self)
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: startOfDay)
        components.weekday = 2
        
        guard let monday = calendar.date(from: components) else { return [] }
        
        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: monday)
        }
    }

    var weekOfMonthString: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let week = calendar.component(.weekOfMonth, from: self)
        return "\(month)월 \(week)주차"
    }
}
