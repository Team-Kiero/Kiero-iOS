//
//  WriteMissionViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Foundation
import Combine

final class WriteMissionViewModel: BaseViewModel {
    
    private let service: WriteMissionServiceType
    let childId: Int
    
    let isMissionAddSuccess = PassthroughSubject<Mission, Never>()
    let isMissionUpdateSuccess = PassthroughSubject<Void, Never>()

    init(service: WriteMissionServiceType, childId: Int) {
        self.service = service
        self.childId = childId
        super.init()
    }
    
    func createMission(name: String, reward: Int, dueAt: String) {
        let request = WriteMissionRequestDTO(name: name, reward: reward, dueAt: dueAt)
        
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
    
    func updateMission(id: Int, name: String, reward: Int, dueAt: String) {
        print("🚀 미션 수정 API 대기 중 - ID: \(id), Name: \(name)")
        
        // TODO: 서버 수정 API 연결
    }
}
