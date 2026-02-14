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
    
    var WeekOfMonth: Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let firstDayOfMonth = calendar.date(from: components) else { return 1 }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = (firstWeekday + 5) % 7
        
        return ((day + offset - 1) / 7) + 1
    }
    
    var WeekOfMonthString: String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        return "\(month)월 \(self.WeekOfMonth)주차"
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
}
