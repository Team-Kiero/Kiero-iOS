//
//  RewardViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import Combine
import SwiftUI

// MARK: - Model

struct Reward: Identifiable, Equatable {
    let id: Int
    let title: String
    let cost: Int
}

// MARK: - ViewModel

final class RewardViewModel: ObservableObject {
    
    @Published var rewards: [Reward] = []
    @Published var selectedReward: Reward? = nil
    @Published var showDeleteDialog: Bool = false
    
    init() {
        fetchRewards()
    }
    
    func addReward(title: String, cost: Int) {
        let nextId = (rewards.map { $0.id }.max() ?? 0) + 1
        let newReward = Reward(id: nextId, title: title, cost: cost)
        
        self.rewards.insert(newReward, at: 0)
    }
    
    func fetchRewards() {
        // TODO: 서버 통신 로직
        self.rewards = [
            Reward(id: 1, title: "용돈 5,000원 받기", cost: 350),
            Reward(id: 2, title: "치킨 시켜먹기", cost: 120),
            Reward(id: 3, title: "게임 1시간 추가", cost: 100),
            Reward(id: 4, title: "친구랑 놀러가기", cost: 500),
            Reward(id: 5, title: "새 신발 사기", cost: 300),
            Reward(id: 6, title: "새 신발 사기", cost: 300),
            Reward(id: 7, title: "새 신발 사기", cost: 300),
            Reward(id: 8, title: "새 신발 사기", cost: 300),
            Reward(id: 9, title: "새 신발 사기", cost: 300)
        ]
    }
    
    func updateReward(id: Int, title: String, cost: Int) {
        if let index = rewards.firstIndex(where: { $0.id == id }) {
            self.rewards[index] = Reward(id: id, title: title, cost: cost)
        }
    }
    
    func deleteReward(reward: Reward) {
        if let index = rewards.firstIndex(where: { $0.id == reward.id }) {
            rewards.remove(at: index)
        }
        
        self.showDeleteDialog = false
        self.selectedReward = nil
    }
}
