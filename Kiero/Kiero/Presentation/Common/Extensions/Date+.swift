//
//  Date+.swift
//  Kiero
//
//  Created by 신혜연 on 1/17/26.
//

import Foundation

extension String {
    func toDate(format: String = "yyyy-MM-dd") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.date(from: self)
    }
}

extension Date {
    var toFullDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd.(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    var toHeaderDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d(E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }

    var daysOfWeek: [Date] {
        let calendar = Calendar.current
        var calendarWithMonday = calendar
        calendarWithMonday.firstWeekday = 2
        
        let components = calendarWithMonday.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        guard let startOfWeek = calendarWithMonday.date(from: components) else { return [] }
        
        return (0..<7).compactMap { day in
            calendarWithMonday.date(byAdding: .day, value: day, to: startOfWeek)
        }
    }
    
    func toString(format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }
    
    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }
    
    var weekOfMonthString: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let week = calendar.component(.weekOfMonth, from: self)
        return "\(month)월 \(week)주차"
    }
}
