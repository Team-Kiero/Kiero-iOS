//
//  DailyJourneyViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/13/26.
//

import UIKit
import Combine

enum DailyJourneyRoute {
    case showNextJourneyDialogBox
    case showCamera
}

struct DailyJourneyViewData {
    let kkubiImageName: String
    let bubbleText: String
    let highlightKeywords: [String]
    let journeyTimeText: String
    let isMissionActive: Bool
    let kidName: String
    let dateText: String
    let coinCount: Int
    let fireStoneCount: Int
    let maxFireStoneCount: Int
    let scheduleOrder: Int
}

final class DailyJourneyViewModel: BaseViewModel, ViewModelType {
    
    // MARK: - Input & Output
    
    struct Input {
        let viewWillAppear: AnyPublisher<Void, Never>
        let nextJourneyButtonTap: AnyPublisher<Void, Never>
        let verifyButtonTap: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let viewData: AnyPublisher<DailyJourneyViewData, Never>
        let route: AnyPublisher<DailyJourneyRoute, Never>
    }
    
    // MARK: - Properties
    
    private let routeSubject = PassthroughSubject<DailyJourneyRoute, Never>()
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        
        input.nextJourneyButtonTap
            .sink { [weak self] in
                self?.routeSubject.send(.showNextJourneyDialogBox)
            }
            .store(in: &cancellables)
        
        input.verifyButtonTap
            .sink { [weak self] in
                self?.routeSubject.send(.showCamera)
            }
            .store(in: &cancellables)
        
        let viewDataOutput = input.viewWillAppear
            .map { [weak self] _ -> DailyJourneyViewData in
                guard let self = self else { return self!.makeErrorViewData() }
                
                // 원하는 시나리오의 주석을 해제하여 확인
                
                // Case 1: 현재 일정 진행중 (NOW_SCHEDULE_EXIST)
                return self.makeScheduleExistData()
                
                // Case 2: 금일 일정 없음 (NO_SCHEDULE)
                // return self.makeNoScheduleData()
                
                // Case 3: 모든 일정 완료, 불 안 킴 (FIRE_NOT_LIT)
                // return self.makeFireNotLitData()
            }
            .eraseToAnyPublisher()
        
        return Output(
            viewData: viewDataOutput,
            route: routeSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Mock Data Helper Methods
    
    // TODO: - 명세서의 로직을 여기에 구현
    
    private func makeScheduleExistData() -> DailyJourneyViewData {
        let scheduleOrder = 4
        let name = "피아노 학원 가기"
        let stoneType = "용기의 불조각"
        
        return DailyJourneyViewData(
            kkubiImageName: "intro_1",
            bubbleText: "오늘도 내 불씨를 키워주러 왔구나!\n우리의 \(scheduleOrder)번째 여정은 \(name) 야!",
            highlightKeywords: [name, stoneType],
            journeyTimeText: "오후 02:00 ~ 오후 04:00",
            isMissionActive: true,
            kidName: "현서",
            dateText: "12월 5일 목요일",
            coinCount: 350,
            fireStoneCount: 1,
            maxFireStoneCount: 7,
            scheduleOrder: scheduleOrder
        )
    }
    
    private func makeNoScheduleData() -> DailyJourneyViewData {
        return DailyJourneyViewData(
            kkubiImageName: "gif_intro",
            bubbleText: "오늘은 예정된 여정이 없어.\n푹 쉬고 내일 만나자!",
            highlightKeywords: [],
            journeyTimeText: "-",
            isMissionActive: false,
            kidName: "근영",
            dateText: "12월 5일 목요일",
            coinCount: 350,
            fireStoneCount: 1,
            maxFireStoneCount: 7,
            scheduleOrder: 9
        )
    }
    
    private func makeFireNotLitData() -> DailyJourneyViewData {
        return DailyJourneyViewData(
            kkubiImageName: "gif_intro",
            bubbleText: "모든 여정을 마쳤어!\n이제 불을 피우러 가볼까?",
            highlightKeywords: ["불 피우기"],
            journeyTimeText: "-",
            isMissionActive: false,
            kidName: "근영",
            dateText: "12월 5일 목요일",
            coinCount: 350,
            fireStoneCount: 1,
            maxFireStoneCount: 7,
            scheduleOrder: 9
        )
    }
    
    private func makeErrorViewData() -> DailyJourneyViewData {
        return DailyJourneyViewData(
            kkubiImageName: "gif_intro",
            bubbleText: "데이터를 불러오지 못했어요.",
            highlightKeywords: [],
            journeyTimeText: "-",
            isMissionActive: false,
            kidName: "근영",
            dateText: "12월 5일 목요일",
            coinCount: 350,
            fireStoneCount: 1,
            maxFireStoneCount: 7,
            scheduleOrder: 9
        )
    }
}
