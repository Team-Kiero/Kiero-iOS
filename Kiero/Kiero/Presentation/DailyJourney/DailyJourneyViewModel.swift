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
    
    // MARK: - Network Logic (Combine Style)
    
    private func fetchDailyJourney() {
        // Child 없이 단독 호출
        DailyJourneyService.shared.updateDailyJourney()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ Fetch Error: \(error)")
                    self?.viewDataSubject.send(self?.makeErrorViewData() ?? DailyJourneyModel.empty)
                }
            } receiveValue: { [weak self] dto in
                guard let self = self else { return }
                
                // 1. ID 저장
                self.currentScheduleDetailId = dto.scheduleDetailId
                
                // 2. 모델 변환 (DTO 1개만 전달)
                let model = self.convertDTOToModel(dto)
                self.viewDataSubject.send(model)
            }
            .store(in: &cancellables)
    }
    
    private func skipSchedule() {
        // 🔍 [로그 1] 함수가 호출되었는지 확인
        print("📢 [ViewModel] skipSchedule() 함수 호출됨!")
        
        guard let id = currentScheduleDetailId else {
            // 🔍 [로그 2] ID가 없어서 막혔는지 확인
            print("⚠️ [ViewModel] 저장된 스케줄 ID가 없습니다. (fetch가 먼저 안 됐거나 실패함)")
            return
        }
        
        // 🔍 [로그 3] 실제 API 요청 시작 확인
        print("🚀 [ViewModel] API 요청 시작! (ID: \(id))")
        
        DailyJourneyService.shared.skipJourney(scheduleDetailId: id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ Skip Error: \(error)")
                }
            } receiveValue: { dto in
                print("✅ 건너뛰기 성공! (서버 응답 받음)")
                // ... 기존 로직 ...
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Converter (DTO -> Model)
    
    private func convertDTOToModel(_ dto: DailyJourneyDTO) -> DailyJourneyModel {
        
        // ⚠️ Child API 연결 전 임시 데이터
        let kidName = "친구" // 나중에 ChildDTO에서 가져와야 함
        let coinCount = 0   // 나중에 ChildDTO에서 가져와야 함
        let todayDateText = "1월 99일" // 나중에 ChildDTO에서 가져와야 함
        
        // Schedule 데이터 가공
        let orderText = convertToKoreanOrdinal(dto.scheduleOrder)
        let scheduleName = dto.name ?? ""
        let stoneTypeName = convertStoneTypeToKorean(dto.stoneType)
        let timeText = formatTimeRange(start: dto.startTime, end: dto.endTime)
        
        switch dto.scheduleStatus {
        case .noSchedule:
            return DailyJourneyModel(
                bubbleText: "오늘은 휴식의 날인가봐!\n푹 쉬면서 내일의 여정을 위한 힘을 모으자!",
                highlightKeywords: [],
                journeyTimeText: "-",
                isMissionActive: true, // 나중에 false로 바꾸기
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: dto.earnedStones ?? 0,
                maxFireStoneCount: dto.totalSchedule,
                scheduleOrder: dto.scheduleOrder,
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
                fireStoneCount: dto.earnedStones ?? 0,
                maxFireStoneCount: dto.totalSchedule,
                scheduleOrder: dto.scheduleOrder,
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
                fireStoneCount: dto.earnedStones ?? 0,
                maxFireStoneCount: dto.totalSchedule,
                scheduleOrder: dto.scheduleOrder,
                scheduleOrderText: "",
                speechFieldType: .no
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func makeErrorViewData() -> DailyJourneyModel {
        // 기존 에러 뷰 데이터 생성 로직 유지
        return DailyJourneyModel.empty // (DailyJourneyModel에 empty static var가 없다면 기존처럼 직접 생성)
    }
    
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

// 없으면
extension DailyJourneyModel {
    static var empty: DailyJourneyModel {
        return DailyJourneyModel(
            bubbleText: "로딩 실패", highlightKeywords: [], journeyTimeText: "오전 3 : 00 ~ 오후 8 : 00", isMissionActive: true,
            kidName: "현서", dateText: "12월 10일", coinCount: 350, fireStoneCount: 4, maxFireStoneCount: 7,
            scheduleOrder: 3, scheduleOrderText: "ㅎㅎ", speechFieldType: .gray
        )
    }
}
