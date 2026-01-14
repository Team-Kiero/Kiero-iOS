//
//  ScheduleViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import Foundation
import Combine

struct MockSchedule {
    let name: String
    let startTime: String
    let endTime: String
    let dayIndex: Int
    let colorCode: String
}

final class ScheduleViewModel: BaseViewModel, ViewModelType {
    
    // MARK: - Input / Output
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let schedules: AnyPublisher<[MockSchedule], Never>
    }
    
    // MARK: - Properties
    
    private let scheduleList = CurrentValueSubject<[MockSchedule], Never>([])

    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .sink { [weak self] in
                self?.fetchDummySchedules()
            }
            .store(in: &cancellables)
            
        return Output(schedules: scheduleList.eraseToAnyPublisher())
    }
    
    // MARK: - Methods
    
    private func fetchDummySchedules() {
        let dummy = [
            MockSchedule(name: "학교", startTime: "08:00:00", endTime: "12:00:00", dayIndex: 0, colorCode: "#007F5F"),
            MockSchedule(name: "수영", startTime: "15:30:00", endTime: "16:30:00", dayIndex: 0, colorCode: "#8ECAE6"),
            MockSchedule(name: "수학", startTime: "17:30:00", endTime: "18:30:00", dayIndex: 0, colorCode: "#FFB703"),
            MockSchedule(name: "영어", startTime: "18:30:00", endTime: "19:30:00", dayIndex: 0, colorCode: "#A8E6CF"),
            MockSchedule(name: "학교", startTime: "08:00:00", endTime: "12:00:00", dayIndex: 1, colorCode: "#007F5F"),
            MockSchedule(name: "돌봄 교실", startTime: "12:30:00", endTime: "17:30:00", dayIndex: 1, colorCode: "#219EBC"),
            MockSchedule(name: "수학", startTime: "17:30:00", endTime: "18:30:00", dayIndex: 1, colorCode: "#FFB703"),
            MockSchedule(name: "영어", startTime: "18:30:00", endTime: "19:30:00", dayIndex: 1, colorCode: "#A8E6CF"),
            MockSchedule(name: "학교", startTime: "08:00:00", endTime: "12:00:00", dayIndex: 2, colorCode: "#007F5F"),
            MockSchedule(name: "돌봄 교실", startTime: "12:30:00", endTime: "13:30:00", dayIndex: 2, colorCode: "#219EBC"),
            MockSchedule(name: "피아노", startTime: "14:00:00", endTime: "15:00:00", dayIndex: 2, colorCode: "#8ECAE6"),
            MockSchedule(name: "수영", startTime: "15:30:00", endTime: "16:30:00", dayIndex: 2, colorCode: "#8ECAE6"),
            MockSchedule(name: "학교", startTime: "08:00:00", endTime: "12:00:00", dayIndex: 3, colorCode: "#007F5F"),
            MockSchedule(name: "태권도", startTime: "12:30:00", endTime: "13:30:00", dayIndex: 3, colorCode: "#FB8500"),
            MockSchedule(name: "돌봄 교실", startTime: "13:30:00", endTime: "14:30:00", dayIndex: 3, colorCode: "#219EBC"),
            MockSchedule(name: "수영", startTime: "15:30:00", endTime: "16:30:00", dayIndex: 3, colorCode: "#8ECAE6"),
            MockSchedule(name: "영어", startTime: "18:30:00", endTime: "19:30:00", dayIndex: 3, colorCode: "#A8E6CF"),
            MockSchedule(name: "학교", startTime: "08:00:00", endTime: "12:00:00", dayIndex: 4, colorCode: "#007F5F"),
            MockSchedule(name: "돌봄 교실", startTime: "12:30:00", endTime: "13:30:00", dayIndex: 4, colorCode: "#219EBC"),
            MockSchedule(name: "태권도", startTime: "09:00:00", endTime: "11:00:00", dayIndex: 5, colorCode: "#FB8500"),
            MockSchedule(name: "피아노", startTime: "12:00:00", endTime: "13:00:00", dayIndex: 5, colorCode: "#8ECAE6"),
            MockSchedule(name: "학교", startTime: "08:00:00", endTime: "12:00:00", dayIndex: 6, colorCode: "#007F5F")
        ]
        scheduleList.send(dummy)
    }
}
