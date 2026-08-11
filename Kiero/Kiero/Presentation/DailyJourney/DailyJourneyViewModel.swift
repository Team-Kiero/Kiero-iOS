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
    case showEndJourneyDialogBox
    case showCamera
    case tryLightFire
}

final class DailyJourneyViewModel: BaseViewModel, ViewModelType {
    
    private let wishWellService = WishWellService()
    public var currentScheduleDetailId: Int?
    private(set) var currentStoneType: StoneType?
    private var currentButtonType: DailyJourneyModel.ActionButtonType = .hidden
    public var currentEarnedStoneCount: Int = 0
    private var isCurrentlyLastJourney = false
    
    // MARK: - Input & Output
    
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let viewWillDisappear: AnyPublisher<Void, Never>
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
            .sink { [weak self] in 
                self?.fetchDailyJourney()
                self?.startSseConnection()
            }
            .store(in: &cancellables)
        
        input.nextJourneyButtonTap
            .sink { [weak self] in
                if self?.isCurrentlyLastJourney == true {
                    self?.routeSubject.send(.showEndJourneyDialogBox)
                } else {
                    self?.routeSubject.send(.showNextJourneyDialogBox)
                }
            }
            .store(in: &cancellables)
        
        input.verifyButtonTap
            .sink { [weak self] in
                guard let self = self else { return }
                switch self.currentButtonType {
                case .verify:
                    self.routeSubject.send(.showCamera)
                case .lightFire:
                    self.routeSubject.send(.tryLightFire)
                case .hidden:
                    break
                }
            }
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
            
            self.currentScheduleDetailId = scheduleDTO.scheduleDetailId
            self.currentStoneType = scheduleDTO.stoneType
            self.currentEarnedStoneCount = scheduleDTO.earnedStones ?? 0
            
            let model = self.convertDTOToModel(schedule: scheduleDTO, child: childInfo)
            self.viewDataSubject.send(model)
        }
        .store(in: &cancellables)
    }
    
    private func skipSchedule() {
        print("📢 skipSchedule() 함수 호출됨")
        
        guard let id = currentScheduleDetailId else { return }
        
        DailyJourneyService.shared.skipJourney(scheduleDetailId: id)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("⚠️ 건너뛰기 결과(에러 포함): \(error)")
                    print("✅ 서버 처리는 완료되었으므로 다음 여정 불러오기 실행")
                    self.fetchDailyJourney()
                }
            } receiveValue: { [weak self] _ in
                AmplitudeManager.shared.track(.scheduleSkipped)
                self?.fetchDailyJourney()
            }
            .store(in: &cancellables)
    }
    
    
    
    // MARK: - SSE Logic
    
    func startSseConnection() {
        print("✅ [DailyJourneyViewModel] startSseConnection called")
        
        Task {
            var token = TokenManager.shared.getSseToken()
            
            if token == nil {
                print("⚠️ [DailyJourneyViewModel] No SSE Token found. Reissuing...")
                do {
                    token = try await TokenRefresher.shared.reissueSseAccessToken()
                    print("✅ [DailyJourneyViewModel] SSE Token reissued successfully.")
                } catch {
                    print("❌ [DailyJourneyViewModel] Failed to reissue SSE Token: \(error)")
                    return
                }
            }
            
            guard let validToken = token else { return }
            
            await MainActor.run {
                SseStreamManager.shared.startIfNeeded(initialToken: validToken) { [weak self] payload in
                    guard payload.eventType == "SCHEDULE_STATUS_UPDATED"
                       || payload.eventType == "SCHEDULE_MODIFIED"
                       || payload.eventType == "DATE_CHANGED" else { return }
                    print("📩 [DailyJourneyViewModel] SSE Event received: \(payload.eventType)")
                    self?.fetchDailyJourney()
                }
            }
        }
    }
    
    // MARK: - Converter
    
    private func convertDTOToModel(schedule: DailyJourneyDTO, child: ChildrenInfo) -> DailyJourneyModel {
        
        let earnedStones = schedule.earnedStones ?? 0
        let totalSchedule = schedule.totalSchedule
        
        let kidName = child.firstName
        let coinCount = child.coinAmount
        let todayDateText = child.today
        
        let orderText = convertToKoreanOrdinal(schedule.scheduleOrder)
        let scheduleName = schedule.name ?? ""
        let stoneTypeName = convertStoneTypeToKorean(schedule.stoneType)
        let timeText = formatTimeRange(start: schedule.startTime, end: schedule.endTime)
        let isTimeViewActive = (timeText != "-")
        
        let isLastJourney = (schedule.scheduleOrder > 0 && schedule.scheduleOrder == totalSchedule)

        self.isCurrentlyLastJourney = isLastJourney

        let isCurrentTimeMatched = isCurrentTimeInSchedule(start: schedule.startTime, end: schedule.endTime)
        
        let buttonType: DailyJourneyModel.ActionButtonType
        let isScheduleActive = (schedule.scheduleStatus == .nowScheduleExist ||
                                schedule.scheduleStatus == .firstSchedule ||
                                schedule.scheduleStatus == .nextScheduleExist)
        
        if isScheduleActive && !schedule.isNowScheduleVerified {
            buttonType = .verify
        }
        else if schedule.scheduleStatus == .fireNotLit && earnedStones > 0 {
            buttonType = .lightFire
        }
        else {
            buttonType = .hidden
        }
        
        self.currentButtonType = buttonType
        
        
        switch schedule.scheduleStatus {
        case .firstSchedule, .nowScheduleExist, .nextScheduleExist:
            let bubbleText: String
            
            if schedule.scheduleStatus == .nowScheduleExist ||
                (schedule.scheduleStatus == .firstSchedule && isCurrentTimeMatched) {
                
                bubbleText = "지금은 \(scheduleName)의 시간이야!\n여정을 진행하면 \(stoneTypeName) 을 줄게."
                
            } else if schedule.scheduleStatus == .firstSchedule {
                bubbleText = "오늘도 내 불씨를 키워주러 왔구나!\n우리의 \(orderText)번째 여정은 \(scheduleName)!"
                
            } else {
                bubbleText = "다음은 \(scheduleName)의 시간이야!\n다음 여정을 진행하면 \(stoneTypeName) 을 줄게."
            }
            
            return DailyJourneyModel(
                bubbleText: bubbleText,
                highlightKeywords: [scheduleName, stoneTypeName],
                journeyTimeText: timeText,
                isMissionActive: true,
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: earnedStones,
                maxFireStoneCount: totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: orderText,
                speechFieldType: isLastJourney ? .endJourney : .gray,
                chipItemType: .inProgressChip,
                isTimeViewActive: isTimeViewActive,
                actionButtonType: buttonType
            )
            
        case .noSchedule:
            let hasCompletedAnySchedule = (totalSchedule > 0 && earnedStones > 0)
            
            let bubbleText = hasCompletedAnySchedule
            ? "오늘의 여정은 모두 끝났어.\n내일도 우리 함께하자!"
            : "오늘은 휴식의 날인가봐!\n푹 쉬면서 내일의 여정을 위한 힘을 모으자!"
            
            return DailyJourneyModel(
                bubbleText: bubbleText,
                highlightKeywords: [],
                journeyTimeText: "-",
                isMissionActive: false,
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: earnedStones,
                maxFireStoneCount: totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: "",
                speechFieldType: .no,
                chipItemType: hasCompletedAnySchedule ? .completedChip : .inProgressChip,
                isTimeViewActive: false,
                actionButtonType: buttonType
            )
            
        case .fireNotLit:
            if earnedStones == 0 {
                return DailyJourneyModel(
                    bubbleText: "오늘은 휴식의 날인가봐!\n푹 쉬면서 내일의 여정을 위한 힘을 모으자!",
                    highlightKeywords: [],
                    journeyTimeText: "-",
                    isMissionActive: false,
                    kidName: kidName,
                    dateText: todayDateText,
                    coinCount: coinCount,
                    fireStoneCount: 0,
                    maxFireStoneCount: totalSchedule,
                    scheduleOrder: schedule.scheduleOrder,
                    scheduleOrderText: "",
                    speechFieldType: .no,
                    chipItemType: .inProgressChip,
                    isTimeViewActive: false,
                    actionButtonType: .hidden
                )
            }
            
            return DailyJourneyModel(
                bubbleText: "고마워 \(kidName)!\n오늘의 조각들이 모두 모였어! 영웅의 불꽃 을 피워줘!",
                highlightKeywords: ["영웅의 불꽃"],
                journeyTimeText: "-",
                isMissionActive: false,
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: earnedStones,
                maxFireStoneCount: totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: "",
                speechFieldType: .no,
                chipItemType: .highlightChip,
                isTimeViewActive: false,
                actionButtonType: buttonType
            )
            
        case .fireLit:
            return DailyJourneyModel(
                bubbleText: "오늘의 여정은 모두 끝났어.\n내일도 우리 함께하자!",
                highlightKeywords: [],
                journeyTimeText: "-",
                isMissionActive: false,
                kidName: kidName,
                dateText: todayDateText,
                coinCount: coinCount,
                fireStoneCount: earnedStones,
                maxFireStoneCount: totalSchedule,
                scheduleOrder: schedule.scheduleOrder,
                scheduleOrderText: "",
                speechFieldType: .no,
                chipItemType: .completedChip,
                isTimeViewActive: false,
                actionButtonType: buttonType
            )
        }
    }
    
    // MARK: - Helper Methods
    
    private func isCurrentTimeInSchedule(start: String?, end: String?) -> Bool {
        guard let start = start, let end = end else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        formatter.locale = Locale(identifier: "ko_KR")
        
        let now = Date()
        let calendar = Calendar.current
        
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: now)
        
        guard let startDateOrigin = formatter.date(from: start),
              let endDateOrigin = formatter.date(from: end) else { return false }
        
        let startComponents = calendar.dateComponents([.hour, .minute, .second], from: startDateOrigin)
        let endComponents = calendar.dateComponents([.hour, .minute, .second], from: endDateOrigin)
        
        guard let startDate = calendar.date(byAdding: startComponents, to: calendar.date(from: todayComponents)!),
              let endDate = calendar.date(byAdding: endComponents, to: calendar.date(from: todayComponents)!) else {
            return false
        }
        
        return now >= startDate && now <= endDate
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
        case .grit: return "인내의 불조각"
        case .courage: return "용기의 불조각"
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
