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
                guard let self = self else { return }
                
                let recentActivityIds = UserDefaults.standard.array(forKey: "recentActivityIds") as? [Int] ?? []

                var activityOrderMap: [Int: Int] = [:]
                var order = 0
                for id in recentActivityIds {
                    activityOrderMap[id] = order
                    order += 1
                }

                let finalGroups = response.missionsByDate
                    .sorted { $0.dueAt < $1.dueAt }
                    .map { group -> MissionGroupDTO in
                        let sortedMissions = group.missions.sorted { m1, m2 in
                            let o1 = activityOrderMap[m1.id]
                            let o2 = activityOrderMap[m2.id]

                            guard o1 != nil || o2 != nil else { return m1.id > m2.id }
                            if o1 == nil { return false }
                            if o2 == nil { return true }

                            return o1! > o2!
                        }
                        return MissionGroupDTO(dueAt: group.dueAt, dayOfWeek: group.dayOfWeek, missions: sortedMissions)
                    }
                
                self.missionGroups = finalGroups
            }
            .store(in: &cancellables)
    }
    
    func deleteMission(id: Int) {
        service.deleteMission(missionId: id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("미션 삭제 실패: \(error)")
                }
            }, receiveValue: { [weak self] in
                self?.fetchMissions()
            })
            .store(in: &cancellables)
    }
}
