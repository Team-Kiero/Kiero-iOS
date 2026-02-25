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
    private let context: AppContextProviding
    
    init(service: MissionServiceType, context: AppContextProviding) {
        self.service = service
        self.context = context
        super.init()
    }
    
    func fetchMissions() {
        let selectedChildId = context.selectedChildId
        let childId = selectedChildId == 0 ? nil : selectedChildId
        
        service.fetchMissions(childId: childId)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("❌ 미션 조회 실패: \(error)")
                }
            } receiveValue: { [weak self] response in
                guard let self = self else { return }
                
                let sortedGroups = response.missionsByDate.sorted { $0.dueAt < $1.dueAt }
                
                let finalGroups = sortedGroups.map { group -> MissionGroupDTO in
                    let sortedMissions = group.missions.sorted { (m1, m2) -> Bool in
                        if m1.id != m2.id {
                            return m1.id < m2.id
                        }
                        
                        return m1.name < m2.name
                    }
                    
                    return MissionGroupDTO(
                        dueAt: group.dueAt,
                        dayOfWeek: group.dayOfWeek,
                        missions: sortedMissions
                    )
                }
                
                self.missionGroups = finalGroups
            }
            .store(in: &cancellables)
    }
    
    func addMission(_ mission: Mission) {
        fetchMissions()
        print("🚀 새로운 미션 추가 시도: \(mission.name)")
    }
}
