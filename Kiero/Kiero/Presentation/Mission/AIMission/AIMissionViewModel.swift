//
//  AIMissionViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Foundation
import Combine

final class AIMissionViewModel: BaseViewModel {
    private let service: AIMissionServiceType
    
    let suggestionResult = PassthroughSubject<[SuggestedMissionDTO], Never>()
    let isLoading = CurrentValueSubject<Bool, Never>(false)

    init(service: AIMissionServiceType) {
        self.service = service
        super.init()
    }

    func analyzeNotice(text: String) {
        isLoading.send(true)
        
        service.postMissionSuggestions(text: text)
            .sink { [weak self] completion in
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                    print("❌ 알림장 분석 에러: \(error)")
                }
            } receiveValue: { [weak self] missions in
                self?.suggestionResult.send(missions)
            }
            .store(in: &cancellables)
    }
}
