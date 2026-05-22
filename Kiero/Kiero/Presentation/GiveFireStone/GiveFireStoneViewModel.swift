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
    
    private let dailyJourneyService: DailyJourneyServiceType
    
    init(
        count: Int,
        dailyJourneyService: DailyJourneyServiceType
    ) {
        self.earnedStoneCount = count
        self.dailyJourneyService = dailyJourneyService
        super.init()
    }
    
    struct Input {
        let didTapGiveButton: AnyPublisher<Void, Never>
        let processViewDidAppear: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let showProcessView: AnyPublisher<Void, Never>
        let showResultView: AnyPublisher<(Int, [String]), Never>
        let showError: AnyPublisher<String, Never>
    }
    
    private let transitionSubject = PassthroughSubject<Void, Never>()
    private let resultSubject = PassthroughSubject<(Int, [String]), Never>()
    private let errorSubject = PassthroughSubject<String, Never>()
    
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
    
    private func requestLightFire() {
        print("🚀 [GiveFireStoneVM] 마음의 불 피우기 API 요청 시작")
        
        dailyJourneyService.lightFire()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ [GiveFireStoneVM] 불꽃 피우기 실패: \(error)")
                    self?.errorSubject.send("불꽃을 전달하는 중 문제가 발생했어요.")
                }
            } receiveValue: { [weak self] data in
                print("✅ [GiveFireStoneVM] 성공! 획득 코인: \(data.earnedCoinAmount), 불조각: \(data.gotStones)")
                self?.resultSubject.send((data.earnedCoinAmount, data.gotStones))
            }
            .store(in: &cancellables)
    }
}
