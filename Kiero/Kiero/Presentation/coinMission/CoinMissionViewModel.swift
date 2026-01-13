//
//  CoinMissionViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 1/13/26.
//

import Foundation
import Combine

struct DailyMissionData {
    let date: Date
    let missions: [(name: String, reward: Int, isCompleted: Bool)]
}

final class CoinMissionViewModel: BaseViewModel, ViewModelType {
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let missionData: AnyPublisher<[DailyMissionData], Never>
    }
    
    let userName: String = "윤아"
    var currentCoinCount: Int = 350
    
    private let missionDataSubject = CurrentValueSubject<[DailyMissionData], Never>([
        DailyMissionData(date: Date(), missions: [
            ("설거지하기", 50, false),
            ("동생 숙제 도와주기", 50, false),
            ("강아지 하리 산책시키기", 50, true)
        ]),
        DailyMissionData(date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, missions: [
            ("방 청소하기", 30, false),
            ("일기 쓰기", 20, false)
        ]),
        DailyMissionData(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!, missions: [
            ("방 청소하기", 30, false),
            ("일기 쓰기", 20, false)
        ]),
    ])
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.missionDataSubject.send(self.missionDataSubject.value)
            }
            .store(in: &cancellables)
            
        return Output(missionData: missionDataSubject.eraseToAnyPublisher())
    }
}
