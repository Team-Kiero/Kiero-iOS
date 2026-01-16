//
//  GiveFireStoneViewModel.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit
import Combine

struct FireStoneResponse: Decodable {
    let gotStones: [String]
    let earnedCoinAmount: Int
}

final class GiveFireStoneViewModel: BaseViewModel, ViewModelType {
    
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
                self?.setDummyResultData()
            }
            .store(in: &cancellables)
        
        return Output(
            showProcessView: transitionSubject.eraseToAnyPublisher(),
            showResultView: resultSubject.eraseToAnyPublisher(),
            showError: errorSubject.eraseToAnyPublisher()
        )
    }
        
    private func setDummyResultData() {
        let coin = 10
        let stones = ["WISDOM"]
        
        self.resultSubject.send((coin, stones))
    }
}
