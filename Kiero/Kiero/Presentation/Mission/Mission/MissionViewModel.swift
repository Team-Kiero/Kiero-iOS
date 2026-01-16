//
//  MissionViewModel.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import Foundation
import Combine

final class MissionViewModel: BaseViewModel {
    
    @Published var missions: [Mission] = []
    
    func fetchMissions() {
        self.missions = [
            Mission(name: "설거지 하기", reward: 50, dueAt: "2026-01-16"),
            Mission(name: "화장실 청소하기", reward: 100, dueAt: "2026-01-17"),
            Mission(name: "방 청소", reward: 30, dueAt: "2026-01-19")
        ]
    }
    
    func addMission(_ mission: Mission) {
        self.missions.append(mission)
        // TODO: 미션 생성 API 호출
    }
}
