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
    let bulkCreateSuccess = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()

    init(service: AIMissionServiceType) {
        self.service = service
        super.init()
    }

    func analyzeNotice(text: String) {
        isLoading.send(true)
        
        service.postMissionSuggestions(text: text)
            .timeout(.seconds(15), scheduler: DispatchQueue.main, customError: {
                return NetworkError.unknownError
            })
            .sink { [weak self] completion in
                self?.isLoading.send(false)
                if case .failure(let error) = completion {
                    print("❌ 알림장 분석 에러: \(error)")
                    self?.errorMessage.send("알림장 내용을 분석하지 못했어요.")
                }
            } receiveValue: { [weak self] missions in
                if missions.isEmpty {
                    self?.errorMessage.send("알림장 내용을 분석하지 못했어요.")
                } else {
                    self?.suggestionResult.send(missions)
                }
            }
            .store(in: &cancellables)
    }
    
    func createBulkMissions(missions: [Mission]) {
        self.isLoading.send(true)
        
        let items = missions.map {
            MissionBulkItemDTO(name: $0.name, reward: $0.reward, dueAt: $0.dueAt)
        }
        
        let childId = UserDefaults.standard.integer(forKey: "selectedChildId")
        
        service.postBulkMissions(childId: childId, missions: items)
            .sink { [weak self] completion in
                self?.isLoading.send(false)
            } receiveValue: { [weak self] response in
                let sortedAiIds = response.sorted { $0.name < $1.name }.reversed().map { $0.id }
                
                var recentActivity = UserDefaults.standard.array(forKey: "recentActivityIds") as? [Int] ?? []
                recentActivity.append(contentsOf: sortedAiIds)
                UserDefaults.standard.set(recentActivity, forKey: "recentActivityIds")
                
                self?.bulkCreateSuccess.send(())
            }
            .store(in: &cancellables)
    }
}
