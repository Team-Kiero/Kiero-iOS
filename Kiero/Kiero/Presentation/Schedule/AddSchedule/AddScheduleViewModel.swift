//
//  AddScheduleViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/13/26.
//

import Foundation
import Combine

final class AddScheduleViewModel: BaseViewModel {
    private let service: AddScheduleServiceType
    private let childId: Int
    var scheduleList: [Schedule] = []
    
    let isAddSuccess = PassthroughSubject<Void, Never>()

    init(service: AddScheduleServiceType, childId: Int) {
        self.service = service
        self.childId = childId
        super.init()
    }

    func addSchedule(
        name: String,
        isRecurring: Bool,
        startTime: String,
        endTime: String,
        color: String,
        dayOfWeek: String?,
        dates: String?
    ) {
        let request = AddScheduleRequestDTO(
            name: name,
            isRecurring: isRecurring,
            startTime: startTime,
            endTime: endTime,
            scheduleColor: color,
            dayOfWeek: dayOfWeek,
            dates: dates
        )

        service.postSchedule(childId: self.childId, request: request)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ 일정 추가 실패: \(error)")
                }
            } receiveValue: { [weak self] _ in
                self?.isAddSuccess.send(())
            }
            .store(in: &cancellables)
    }
}
