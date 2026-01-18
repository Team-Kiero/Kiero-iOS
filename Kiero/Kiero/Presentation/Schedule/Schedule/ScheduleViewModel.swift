//
//  ScheduleViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import Foundation
import Combine

final class ScheduleViewModel: BaseViewModel, ViewModelType {
    
    // MARK: - Properties
    
    private(set) var scheduleList = CurrentValueSubject<[Schedule], Never>([])
    let currentReferenceDate = CurrentValueSubject<Date, Never>(Date())
    
    // MARK: - Input / Output
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let prevWeekTapped: AnyPublisher<Void, Never>
        let nextWeekTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let headerInfo: AnyPublisher<(title: String, leftEnabled: Bool, rightEnabled: Bool), Never>
        let filteredSchedules: AnyPublisher<[Schedule], Never>
        let weeklyDates: AnyPublisher<[Date], Never>
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.prevWeekTapped
            .sink { [weak self] in
                guard let self = self else { return }
                if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: self.currentReferenceDate.value),
                   self.isWithinRange(date: newDate) {
                    self.currentReferenceDate.send(newDate)
                }
            }.store(in: &cancellables)
        
        input.nextWeekTapped
            .sink { [weak self] in
                guard let self = self else { return }
                if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: self.currentReferenceDate.value),
                   self.isWithinRange(date: newDate) {
                    self.currentReferenceDate.send(newDate)
                }
            }.store(in: &cancellables)
        
        let headerInfo = currentReferenceDate
            .map { [weak self] date -> (title: String, leftEnabled: Bool, rightEnabled: Bool) in
                let title = self?.formatWeekTitle(from: date) ?? ""
                let leftEnabled = self?.isWithinRange(date: Calendar.current.date(byAdding: .weekOfYear, value: -1, to: date)!) ?? false
                let rightEnabled = self?.isWithinRange(date: Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date)!) ?? false
                
                return (title: title, leftEnabled: leftEnabled, rightEnabled: rightEnabled)
            }.eraseToAnyPublisher()
        
        let weeklyDates = currentReferenceDate
            .map { $0.daysOfWeek }
            .eraseToAnyPublisher()
        
        let filteredSchedules = Publishers.CombineLatest(scheduleList, currentReferenceDate)
            .map { (schedules, refDate) -> [Schedule] in
                let calendar = Calendar.current
                let currentWeekRange = refDate.daysOfWeek
                
                guard let lastDayOfCurrentWeek = currentWeekRange.last else { return [] }
                let endOfCurrentWeek = calendar.startOfDay(for: lastDayOfCurrentWeek)
                
                return schedules.filter { schedule in
                    if schedule.isRecurring {
                        if let startDateStr = schedule.date,
                           let startDate = startDateStr.toDate(format: "yyyy-MM-dd") {
                            let startDayOfRecurring = calendar.startOfDay(for: startDate)
                            return endOfCurrentWeek >= startDayOfRecurring
                        }
                        return true
                    }
                    
                    if let dateStr = schedule.date,
                       let scheduleDate = dateStr.toDate(format: "yyyy-MM-dd") {
                        return currentWeekRange.contains { calendar.isDate($0, inSameDayAs: scheduleDate) }
                    }
                    return false
                }
            }.eraseToAnyPublisher()
        
        return Output(
            headerInfo: headerInfo,
            filteredSchedules: filteredSchedules,
            weeklyDates: weeklyDates
        )
    }
    
    private func formatWeekTitle(from date: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let day = components.day ?? 1
        let month = components.month ?? 1
        
        if day == 1 {
            return "\(month)월 1주차"
        }
        
        let weekOfMonth = calendar.component(.weekOfMonth, from: date)
        return "\(month)월 \(weekOfMonth)주차"
    }
    
    private func isWithinRange(date: Date) -> Bool {
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        
        guard let minDate = calendar.date(byAdding: .weekOfYear, value: -12, to: now),
              let maxDate = calendar.date(byAdding: .weekOfYear, value: 12, to: now) else { return false }
        
        let targetDate = calendar.startOfDay(for: date)
        return targetDate >= minDate && targetDate <= maxDate
    }
    
    func addSchedule(_ schedule: Schedule) {
        var current = scheduleList.value
        current.append(schedule)
        scheduleList.send(current)
    }
}
