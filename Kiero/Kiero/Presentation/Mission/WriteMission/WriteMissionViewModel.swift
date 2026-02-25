//
//  WriteMissionViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Combine
import Foundation

final class WriteMissionViewModel: BaseViewModel {
    
    private let service: WriteMissionServiceType
    private let context: AppContextProviding
    
    let isMissionAddSuccess = PassthroughSubject<Mission, Never>()

    init(service: WriteMissionServiceType, context: AppContextProviding) {
        self.service = service
        self.context = context
        super.init()
    }
    
    func createMission(name: String, reward: Int, dueAt: String) {
        let request = WriteMissionRequestDTO(name: name, reward: reward, dueAt: dueAt)
        
        let childId = context.selectedChildId
        
        service.postMission(childId: childId, request: request)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ 미션 생성 실패: \(error)")
                }
            } receiveValue: { [weak self] response in
                let newMission = Mission(name: response.name, reward: response.reward, dueAt: response.dueAt)
                self?.isMissionAddSuccess.send(newMission)
            }
            .store(in: &cancellables)
    }
}
