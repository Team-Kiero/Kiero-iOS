//
//  TodayStatusViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 3/2/26.
//

import Combine
import Foundation

final class TodayStatusViewModel: BaseViewModel, ObservableObject {
    
    @Published var completeMissions: [MissionItem] = []
    @Published var incompleteMissions: [MissionItem] = []
    @Published var schedules: [ScheduleItem] = []
    @Published var isFireLitToday: Bool = false
    @Published var selectedScheduleImageURL: URL? = nil
    @Published var childFirstName: String = ""
    
    var currentChildId: Int = 0
    
    override init() {
        super.init()
        
        self.currentChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
    }
    
    func fetchTodayStatus(childId: Int? = nil) {
        let targetId = childId ?? self.currentChildId
        
        TodayStatusService.shared.fetchTodayStatus(childId: targetId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("오늘 현황 조회 성공")
                case .failure(let error):
                    print("오늘 현황 조회 실패: \(error)")
                    Toast.show(message: error.toastMessage)
                }
            } receiveValue: { [weak self] dto in
                guard let self else { return }
                
                self.completeMissions = dto.completeMissions.map { $0.toItem() }
                self.incompleteMissions = dto.incompleteMissions.map { $0.toItem() }
                self.schedules = dto.schedules.map { $0.toItem() }
                self.isFireLitToday = dto.isFireLitToday
                self.childFirstName = dto.firstName
            }
            .store(in: &cancellables)
    }
    
    func postScheduleImage(scheduleDetailId: Int) {
        TodayStatusService.shared.postScheduleImage(scheduleDetailId: scheduleDetailId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("일정 인증 이미지 조회 성공")
                case .failure(let error):
                    print("일정 인증 이미지 조회 실패: \(error)")
                    Toast.show(message: error.toastMessage)
                }
            } receiveValue: { [weak self] response in
                print("imageUrl:", response.imageUrl)
                self?.selectedScheduleImageURL = URL(string: response.imageUrl)
                print("converted URL:", self?.selectedScheduleImageURL as Any)
            }
            .store(in: &cancellables)
    }
    
    func didTapScheduleCard(_ schedule: ScheduleItem) {
        postScheduleImage(scheduleDetailId: schedule.id)
    }
}
