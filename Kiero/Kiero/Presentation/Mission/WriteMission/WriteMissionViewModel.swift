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
    private var userSessionStorage: UserSessionStorageType
    
    let childId: Int
    
    let isMissionAddSuccess = PassthroughSubject<Mission, Never>()
    let isMissionUpdateSuccess = PassthroughSubject<Void, Never>()
    let errorMessage = PassthroughSubject<String, Never>()

    init(
        service: WriteMissionServiceType,
        childId: Int,
        userSessionStorage: UserSessionStorageType
    ) {
        self.service = service
        self.childId = childId
        self.userSessionStorage = userSessionStorage
        super.init()
    }
    
    func createMission(name: String, reward: Int, dueAt: String) {
        let request = WriteMissionRequestDTO(
            name: name,
            reward: reward,
            dueAt: dueAt
        )
        
        service.postMission(childId: childId, request: request)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ 미션 생성 실패: \(error)")
                    self?.errorMessage.send("미션 등록에 실패했어요. 잠시 후 다시 시도해주세요.")
                }
            } receiveValue: { [weak self] response in
                guard let self else { return }
                
                print("🔍 새로 추가된 미션 id: \(response.id)")
                
                var recentActivity = self.userSessionStorage.recentActivityIds
                recentActivity.append(response.id)
                self.userSessionStorage.recentActivityIds = recentActivity
                
                let newMission = Mission(
                    name: response.name,
                    reward: response.reward,
                    dueAt: response.dueAt
                )
                
                self.isMissionAddSuccess.send(newMission)
            }
            .store(in: &cancellables)
    }
    
    func updateMission(id: Int, name: String, reward: Int, dueAt: String) {
        let request = WriteMissionRequestDTO(
            name: name,
            reward: reward,
            dueAt: dueAt
        )
        
        service.updateMission(missionId: id, request: request)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("❌ 미션 수정 실패: \(error)")
                    self?.errorMessage.send("미션 수정에 실패했어요. 잠시 후 다시 시도해주세요.")
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                
                var recentActivity = self.userSessionStorage.recentActivityIds
                recentActivity.removeAll { $0 == id }
                recentActivity.append(id)
                self.userSessionStorage.recentActivityIds = recentActivity
                
                self.isMissionUpdateSuccess.send(())
            }
            .store(in: &cancellables)
    }
}
