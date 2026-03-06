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

final class RewardViewModel: BaseViewModel, ObservableObject {
    
    @Published var rewards: [Reward] = []
    @Published var selectedReward: Reward? = nil
    @Published var showDeleteDialog: Bool = false
    
    var currentChildId: Int = 0
    
    let scrollToTop = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        
        self.currentChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
    }
    
    func addReward(title: String, cost: Int) {
        let nextId = (rewards.map { $0.id }.max() ?? 0) + 1
        let newReward = Reward(id: nextId, title: title, cost: cost)
        
        self.rewards.insert(newReward, at: 0)
    }
    
    func fetchCoupons(childId: Int? = nil) {
        let targetId = childId ?? self.currentChildId
        
        RewardService.shared.fetchCoupons(childId: targetId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("쿠폰 목록 조회 성공")
                case .failure(let error):
                    print("쿠폰 목록 조회 실패: \(error)")
                }
            } receiveValue: { [weak self] rewards in
                self?.rewards = rewards
            }
            .store(in: &cancellables)
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
