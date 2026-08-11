//
//  GiveFireStoneViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import Combine
import UIKit

final class GiveFireStoneViewModel: BaseViewModel, ViewModelType {
    
    let earnedStoneCount: Int
    
    init(count: Int) {
        self.earnedStoneCount = count
    }
    
    // MARK: - Input & Output
    
    struct Input {
        let didTapGiveButton: AnyPublisher<Void, Never>
        let processViewDidAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let showProcessView: AnyPublisher<Void, Never>
        let showResultView: AnyPublisher<(Int, [String]), Never>
        let showError: AnyPublisher<String, Never>
    }
    
    // MARK: - Properties
    
    private let transitionSubject = PassthroughSubject<Void, Never>()
    private let resultSubject = PassthroughSubject<(Int, [String]), Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        
        input.didTapGiveButton
            .sink { [weak self] in
                self?.transitionSubject.send(())
            }
            .store(in: &cancellables)
        
        input.processViewDidAppear
            .sink { [weak self] in
                self?.requestLightFire()
            }
            .store(in: &cancellables)
        
        return Output(
            showProcessView: transitionSubject.eraseToAnyPublisher(),
            showResultView: resultSubject.eraseToAnyPublisher(),
            showError: errorSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Network Logic
    
    private func requestLightFire() {
        print("🚀 [GiveFireStoneVM] 마음의 불 피우기 API 요청 시작")
        
        DailyJourneyService.shared.lightFire()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ [GiveFireStoneVM] 불꽃 피우기 실패: \(error)")
                    self?.errorSubject.send("불꽃을 전달하는 중 문제가 발생했어요.")
                }
            } receiveValue: { [weak self] data in
                print("✅ [GiveFireStoneVM] 성공! 획득 코인: \(data.earnedCoinAmount), 불조각: \(data.gotStones)")

                AmplitudeManager.shared.track(.dailyJourneyCompleted, properties: [
                    AnalyticsEventProperty.earnedCoin: data.earnedCoinAmount,
                    AnalyticsEventProperty.stoneCount: data.gotStones.count
                ])

                self?.resultSubject.send((data.earnedCoinAmount, data.gotStones))
            }
            .store(in: &cancellables)
    }
}
