//
//  DailyJourneyViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/13/26.
//

import Combine
import UIKit

enum DailyJourneyRoute {
    case showNextJourneyDialogBox
    case showCamera
}

final class DailyJourneyViewModel: BaseViewModel, ViewModelType {
    
    private let wishWellService = WishWellService()
    private var currentScheduleDetailId: Int?
    
    // MARK: - Input & Output
    
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let nextJourneyButtonTap: AnyPublisher<Void, Never>
        let verifyButtonTap: AnyPublisher<Void, Never>
        let skipConfirmTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let viewData: AnyPublisher<DailyJourneyModel, Never>
        let route: AnyPublisher<DailyJourneyRoute, Never>
    }
    
    // MARK: - Properties
    
    private let routeSubject = PassthroughSubject<DailyJourneyRoute, Never>()
    private let viewDataSubject = PassthroughSubject<DailyJourneyModel, Never>()
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.viewWillAppear
            .sink { [weak self] in self?.fetchDailyJourney() }
            .store(in: &cancellables)
        
        input.nextJourneyButtonTap
            .sink { [weak self] in self?.routeSubject.send(.showNextJourneyDialogBox) }
            .store(in: &cancellables)
        
        input.verifyButtonTap
            .sink { [weak self] in self?.routeSubject.send(.showCamera) }
            .store(in: &cancellables)
        
        input.skipConfirmTap
            .sink { [weak self] in self?.skipSchedule() }
            .store(in: &cancellables)
        
        return Output(
            viewData: viewDataSubject.eraseToAnyPublisher(),
            route: routeSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Network Logic
    
    private func fetchDailyJourney() {
        // Zip을 사용하여 일정 정보와 아이 정보를 병렬로 호출
        Publishers.Zip(
            DailyJourneyService.shared.updateDailyJourney(),
            self.wishWellService.fetchMyInfo()
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                print("❌ Fetch Error: \(error)")
            }
        } receiveValue: { [weak self] (scheduleDTO, childInfo) in
            guard let self = self else { return }
            
            // 1. ID 저장
            self.currentScheduleDetailId = scheduleDTO.scheduleDetailId
            
            // 2. 두 데이터를 합쳐서 Model 변환
            let model = self.convertDTOToModel(schedule: scheduleDTO, child: childInfo)
            self.viewDataSubject.send(model)
        }
        .store(in: &cancellables)
    }
    
    private func skipSchedule() {
        print("📢 [ViewModel] skipSchedule() 함수 호출됨")
        
        guard let id = currentScheduleDetailId else {
            print("⚠️ [ViewModel] 저장된 스케줄 ID가 없음 (fetch가 먼저 안 됐거나 실패함)")
            return
        }
        
        print("🚀 [ViewModel] API 요청 시작 (ID: \(id))")
        
        Publishers.Zip(
            DailyJourneyService.shared.skipJourney(scheduleDetailId: id),
            self.wishWellService.fetchMyInfo()
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            if case .failure(let error) = completion {
                print("❌ Skip Error: \(error)")
            }
        } receiveValue: { [weak self] (newScheduleDTO, childInfo) in
            guard let self = self else { return }
            
            print("✅ 건너뛰기 성공! (서버 응답 받음)")
            
            // 1. 갱신된 ID 저장
            self.currentScheduleDetailId = newScheduleDTO.scheduleDetailId
            
            // 2. 화면 갱신
            let model = self.convertDTOToModel(schedule: newScheduleDTO, child: childInfo)
            self.viewDataSubject.send(model)
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Converter (DTO -> Model)
    
    private func convertDTOToModel(schedule: DailyJourneyDTO, child: ChildrenInfo) -> DailyJourneyModel {
        
        // 1. Child API 데이터 매핑
        let kidName = child.firstName
        let coinCount = child.coinAmount
        let todayDateText = child.today
        
        // 2. Schedule 데이터 가공
        let orderText = convertToKoreanOrdinal(schedule.scheduleOrder)
        let scheduleName = schedule.name ?? ""
        let stoneTypeName = convertStoneTypeToKorean(schedule.stoneType)
        let timeText = formatTimeRange(start: schedule.startTime, end: schedule.endTime)
        
        switch schedule.scheduleStatus {
        case .noSchedule:
            return DailyJourneyModel(
                bubbleText: "오늘은 휴식의 날인가봐!\n푹 쉬면서 내일의 여정을 위한 힘을 모으자!",
                highlightKeywords: [],
                journeyTimeText: "-",
                isMissionActive: false, 
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: schedule.earnedStones ?? 0,
                maxFireStoneCount: schedule.totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: "",
                speechFieldType: .no
            )
            
        case .nowScheduleExist, .nextScheduleExist, .firstSchedule:
            return DailyJourneyModel(
                bubbleText: "오늘도 내 불씨를 키워주러 왔구나!\n우리의 \(orderText)번째 여정은 \(scheduleName) 야!",
                highlightKeywords: [scheduleName, stoneTypeName],
                journeyTimeText: timeText,
                isMissionActive: true,
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: schedule.earnedStones ?? 0,
                maxFireStoneCount: schedule.totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: orderText,
                speechFieldType: .gray
            )
            
        case .fireNotLit, .fireLit:
            return DailyJourneyModel(
                bubbleText: "모든 여정을 마쳤어!\n이제 불을 피우러 가볼까?",
                highlightKeywords: ["불 피우기"],
                journeyTimeText: "-",
                isMissionActive: false,
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: schedule.earnedStones ?? 0,
                maxFireStoneCount: schedule.totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: "",
                speechFieldType: .no
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func formatTimeRange(start: String?, end: String?) -> String {
        guard let start = start, let end = end else { return "-" }
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.dateFormat = "a hh:mm"
        if let startDate = inputFormatter.date(from: start),
           let endDate = inputFormatter.date(from: end) {
            return "\(outputFormatter.string(from: startDate)) ~ \(outputFormatter.string(from: endDate))"
        }
        return "-"
    }
    
    private func convertStoneTypeToKorean(_ type: StoneType?) -> String {
        guard let type = type else { return "" }
        switch type {
        case .grit: return "용기의 불조각"
        case .courage: return "인내의 불조각"
        case .wisdom: return "지혜의 불조각"
        }
    }
    
    private func convertToKoreanOrdinal(_ number: Int) -> String {
        switch number {
        case 1: return "첫"
        case 2: return "두"
        case 3: return "세"
        case 4: return "네"
        case 5: return "다섯"
        case 6: return "여섯"
        case 7: return "일곱"
        case 8: return "여덟"
        case 9: return "아홉"
        case 10: return "열"
        default: return "\(number)"
        }
    }
}
