//
//  RewardViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import Combine
import SwiftUI

// MARK: - Model

struct Reward: Equatable {
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
            Reward(title: "용돈 5,000원 받기", cost: 350),
            Reward(title: "치킨 시켜먹기", cost: 1200),
            Reward(title: "게임 1시간 추가", cost: 100),
            Reward(title: "친구랑 놀러가기", cost: 500),
            Reward(title: "새 신발 사기", cost: 3000)
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
