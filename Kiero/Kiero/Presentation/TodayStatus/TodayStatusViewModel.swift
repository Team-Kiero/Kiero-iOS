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
    
    private var refreshWorkItem: DispatchWorkItem?
    private var isSseBound = false
    
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
                    print("일정 인증 이미지 조회 완료")
                case .failure(let error):
                    print("일정 인증 이미지 조회 실패: \(error)")
                    Toast.show(message: error.toastMessage)
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                
                let imageUrlString = response.imageUrl.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !imageUrlString.isEmpty else {
                    Toast.show(message: "등록된 인증 이미지가 없어요.")
                    return
                }
                
                guard let url = URL(string: imageUrlString) else {
                    Toast.show(message: "이미지 주소가 올바르지 않아요.")
                    return
                }
                
                self.selectedScheduleImageURL = url
            }
            .store(in: &cancellables)
    }
    
    func didTapScheduleCard(_ schedule: ScheduleItem) {
        postScheduleImage(scheduleDetailId: schedule.id)
    }
    
    func bindSSEIfNeeded() {
        guard !isSseBound else { return }
        isSseBound = true
        
        guard let token = UserDefaults.standard.string(forKey: "sseAccessToken") else {
            print("SSE 토큰 없음")
            return
        }
        
        SseStreamManager.shared.onRefreshWillStart = { [weak self] in
            DispatchQueue.main.async {
                self?.scheduleRefresh()
            }
        }
        
        SseStreamManager.shared.onReconnected = { [weak self] in
            DispatchQueue.main.async {
                self?.scheduleRefresh()
            }
        }
        
        SseStreamManager.shared.startIfNeeded(
            initialToken: token,
            onEvent: { [weak self] payload in
                guard let self else { return }
                
                if self.shouldRefreshTodayStatus(for: payload) {
                    DispatchQueue.main.async {
                        self.scheduleRefresh()
                    }
                }
            }
        )
    }
    
    func unbindSSE() {
        refreshWorkItem?.cancel()
        refreshWorkItem = nil
        isSseBound = false
    }
    
    private func shouldRefreshTodayStatus(for payload: SseEventPayload) -> Bool {
        if let childId = payload.childId,
           Int(childId) != currentChildId {
            return false
        }
        
        switch payload.eventType {
        case "FEED_ITEM_CREATED",
             "SCHEDULE_STATUS_UPDATED",
             "DATE_CHANGED",
             "TODAY_MISSION_COMPLETED",
             "FIRE_LIT":
            return true
        default:
            return false
        }
    }
    
    private func scheduleRefresh() {
        refreshWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.fetchTodayStatus()
        }
        
        refreshWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: workItem)
    }
}
