//
//  MissionViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Foundation
import Combine

final class MissionViewModel: BaseViewModel {
    
    @Published var missionGroups: [MissionGroupDTO] = []
    private let service: MissionServiceType
    
    init(service: MissionServiceType) {
        self.service = service
        super.init()
    }
    
    func fetchMissions() {
        let selectedChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
        let childId = selectedChildId == 0 ? nil : selectedChildId
        
        service.fetchMissions(childId: childId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ 미션 조회 실패: \(error)")
                }
            } receiveValue: { [weak self] response in
                self?.missionGroups = response.missionsByDate
            }
            .store(in: &cancellables)
    }
    
    func addMission(_ mission: Mission) {
        print("🚀 새로운 미션 추가 시도: \(mission.name)")
        fetchMissions()
    }
}
