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
    
    func fetchRewards() {
        // TODO: 서버 통신 로직
        self.rewards = [
            Reward(id: 1, title: "용돈 5,000원 받기", cost: 350),
            Reward(id: 2, title: "치킨 시켜먹기", cost: 1200),
            Reward(id: 3, title: "게임 1시간 추가", cost: 100),
            Reward(id: 4, title: "친구랑 놀러가기", cost: 500),
            Reward(id: 5, title: "새 신발 사기", cost: 3000),
            Reward(id: 6, title: "새 신발 사기", cost: 3000),
            Reward(id: 7, title: "새 신발 사기", cost: 3000),
            Reward(id: 8, title: "새 신발 사기", cost: 3000),
            Reward(id: 9, title: "새 신발 사기", cost: 3000)
        ]
    }
    
    func deleteReward() {
        guard let reward = selectedReward else { return }
        if let index = rewards.firstIndex(of: reward) {
            rewards.remove(at: index)
        }
        
        selectedReward = nil
        showDeleteDialog = false
    }
}
