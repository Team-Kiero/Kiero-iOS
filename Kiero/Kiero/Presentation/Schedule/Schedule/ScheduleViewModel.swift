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
    let logoutSuccess = PassthroughSubject<Void, Never>()
    
    var isFireLit: Bool = false
    
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
            .flatMap { [weak self] (id, date) -> AnyPublisher<(isFireLit: Bool, schedules: [Schedule]), Never> in
                guard let self = self else {
                    return Just((isFireLit: false, schedules: [Schedule]())).eraseToAnyPublisher()
                }
                
                let days = date.daysOfWeek
                guard let startDate = days.first, let endDate = days.last else {
                    return Just((isFireLit: false, schedules: [Schedule]())).eraseToAnyPublisher()
                }
                
                return self.service.fetchSchedules(childId: id, startDate: startDate, endDate: endDate)
                    .replaceError(with: (isFireLit: false, schedules: [Schedule]()))
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] result in
                self?.isFireLit = result.isFireLit
                self?.scheduleList.send(result.schedules)
            }
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
                let now = Date()
                let currentWeekRange = refDate.daysOfWeek
                let currentWeekDayIndex = (calendar.component(.weekday, from: now) + 5) % 7

                return schedules.filter { schedule in
                    if schedule.isRecurring {
                        let isViewingCurrentWeek = calendar.isDate(refDate, inSameDayAs: now) ||
                                                  (currentWeekRange.first! <= now && currentWeekRange.last! >= now)
                        
                        if isViewingCurrentWeek {
                            let scheduleIndices = schedule.dayIndices
                            
                            let isAllPast = scheduleIndices.allSatisfy { dayIndex in
                                if dayIndex < currentWeekDayIndex { return true }
                                if dayIndex == currentWeekDayIndex {
                                    if let scheduleTime = schedule.startTime.toDate(format: "HH:mm:ss") {
                                        let nowMin = calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
                                        let scheduleMin = calendar.component(.hour, from: scheduleTime) * 60 + calendar.component(.minute, from: scheduleTime)
                                        return scheduleMin < nowMin
                                    }
                                }
                                return false
                            }
                            
                            if isAllPast { return false }
                        }
                        return true
                    } else {
                        guard let dateStr = schedule.date else { return false }
                        return currentWeekRange.map { $0.toString(format: "yyyy-MM-dd") }.contains(dateStr)
                    }
                }
            }.eraseToAnyPublisher()
        
        return Output(
            headerInfo: headerInfo,
            filteredSchedules: filteredSchedules,
            weeklyDates: weeklyDates
        )
    }
    
    private func formatWeekTitle(from date: Date) -> String {
        return date.weekOfMonthString
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
    
    func performLogout() {
        service.deleteChildDummyData()
            .handleEvents(receiveSubscription: { _ in
                print("📡 [1단계] 아이 데이터 삭제 API 구독 시작")
            })
            .catch { error in
                print("⚠️ [1단계 에러] 삭제 실패(무시하고 진행): \(error)")
                return Just(())
            }
            .flatMap { [weak self] _ -> AnyPublisher<Void, NetworkError> in
                print("🚀 [2단계] 부모 로그아웃 API 요청 전송")
                guard let self = self else { return Fail(error: .unknownError).eraseToAnyPublisher() }
                return self.service.logout()
            }
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ 최종 로그아웃 실패: \(error)")
                }
            } receiveValue: { [weak self] _ in
                print("✅ 서버 로그아웃 응답 성공")
                TokenManager.shared.clearAll()
                self?.logoutSuccess.send(())
            }
            .store(in: &cancellables)
    }
    
    func deleteSchedule(scheduleId: Int, selectedDate: String, isIncludeFollowing: Bool) {
        service.deleteSchedule(
            scheduleId: scheduleId,
            selectedDate: selectedDate,
            isIncludeFollowing: isIncludeFollowing
        )
        .receive(on: RunLoop.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("삭제 실패: \(error)")
            }
        }, receiveValue: { [weak self] in
            self?.refreshSchedules()
        })
        .store(in: &cancellables)
    }
}
