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
    
    private let scheduleList = CurrentValueSubject<[Schedule], Never>([])
    
    // MARK: - Input / Output
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let schedules: AnyPublisher<[Schedule], Never>
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .sink { [weak self] in
                 self?.scheduleList.send([])
            }
            .store(in: &cancellables)
        
        return Output(schedules: scheduleList.eraseToAnyPublisher())
    }
    
    func addSchedule(_ schedule: Schedule) {
        var currentSchedules = scheduleList.value
        currentSchedules.append(schedule)
        scheduleList.send(currentSchedules)
    }
}
