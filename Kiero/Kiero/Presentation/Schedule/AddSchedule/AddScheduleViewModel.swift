//
//  AddScheduleViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/13/26.
//

import UIKit
import Combine

final class AddScheduleViewModel: BaseViewModel {
    private let service: AddScheduleServiceType
    private let childId: Int
    var scheduleList: [Schedule] = []
    var isFireLit: Bool = false
    
    let isAddSuccess = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()
    let defaultColor = PassthroughSubject<UIColor, Never>()

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
        
        print("📡 [Service] 일정 저장 요청 시작")
        
        service.postSchedule(childId: self.childId, request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                if case .failure(let error) = completion {
                    print("❌ [VM 에러 발생]: \(error)")
                    
                    switch error {
                    case .clientError(let code) where code == 400:
                        self.errorMessage.send("기존의 일정과 시간이 중복됩니다.")
                    default:
                        self.errorMessage.send("일정 저장에 실패했어요. 잠시 후 다시 시도해주세요.")
                    }
                }
            } receiveValue: { [weak self] _ in
                print("✅ [VM] 서버 저장 성공")
                self?.isAddSuccess.send(())
            }
            .store(in: &cancellables)
    }
    
    func fetchDefaultColor() {
        service.fetchDefaultColor(childId: childId)
            .sink { _ in } receiveValue: { [weak self] response in
                let colorMapping: [String: UIColor] = [
                    "SCHEDULE1": .schedule1, "SCHEDULE2": .schedule2,
                    "SCHEDULE3": .schedule3, "SCHEDULE4": .schedule4, "SCHEDULE5": .schedule5
                ]
                let color = colorMapping[response.scheduleColor] ?? .schedule1
                self?.defaultColor.send(color)
            }
            .store(in: &cancellables)
    }
}
