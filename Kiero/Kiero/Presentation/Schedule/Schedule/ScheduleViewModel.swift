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
    
    private let service: ScheduleServiceType
    private let childId = CurrentValueSubject<Int, Never>(0)
    
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
    
    // MARK: - Life Cycle
    
    init(service: ScheduleServiceType, childId: Int) {
        self.service = service
        super.init()
        
        fetchInitialChildId()
    }
    
    private func fetchInitialChildId() {
        service.fetchChildren()
            .sink { _ in } receiveValue: { [weak self] children in
                if let firstChildId = children.first?.childId {
                    self?.childId.send(firstChildId)
                    UserDefaults.standard.set(firstChildId, forKey: "selectedChildId")
                    print("📍 [저장 완료] childId \(firstChildId)를 UserDefaults에 저장했습니다.")
                }
            }
            .store(in: &cancellables)
    }
    
    func refreshSchedules() {
        self.childId.send(self.childId.value)
    }
    
    func transform(input: Input) -> Output {
        Publishers.CombineLatest(childId, currentReferenceDate)
            .filter { id, _ in id != 0 }
            .flatMap { [weak self] (id, date) -> AnyPublisher<[Schedule], Never> in
                guard let self = self else { return Just([]).eraseToAnyPublisher() }
                
                let days = date.daysOfWeek
                guard let startDate = days.first, let endDate = days.last else {
                    return Just([]).eraseToAnyPublisher()
                }
                
                return self.service.fetchSchedules(childId: id, startDate: startDate, endDate: endDate)
                    .replaceError(with: [])
                    .eraseToAnyPublisher()
            }
            .subscribe(scheduleList)
            .store(in: &cancellables)
        
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
                
                print("🔍 [필터링 시작] 전체 일정 개수: \(schedules.count)")
                
                guard let lastDayOfCurrentWeek = currentWeekRange.last else { return [] }
                let endOfCurrentWeek = calendar.startOfDay(for: lastDayOfCurrentWeek)
                
                let filtered = schedules.filter { schedule in
                    if schedule.isRecurring {
                        if let startDateStr = schedule.date,
                           let startDate = startDateStr.toDate(format: "yyyy-MM-dd") {
                            let startDayOfRecurring = calendar.startOfDay(for: startDate)
                            return endOfCurrentWeek >= startDayOfRecurring
                        }
                        return true
                    }
                    
                    if let dateStr = schedule.date {
                        let weekDateStrings = currentWeekRange.map { $0.toString(format: "yyyy-MM-dd") }
                        let isIncluded = weekDateStrings.contains(dateStr)
                        
                        if !isIncluded {
                            print("📌 일정 제외됨: \(schedule.name) (날짜: \(dateStr)) - 현재 주차 범위에 없음")
                        }
                        return isIncluded
                    }
                    return false
                }
                
                print("🎯 [필터링 완료] 화면에 그려질 일정 개수: \(filtered.count)")
                return filtered
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
