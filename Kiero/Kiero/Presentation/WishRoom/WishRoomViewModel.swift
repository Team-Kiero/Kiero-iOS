//
//  WishRoomViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 5/22/26.
//

import Foundation

final class WishRoomViewModel: ObservableObject {
    
    @Published var todayWishes: [WishItem] = []
    @Published var previousWishes: [WishItem] = []
    @Published var isLoading: Bool = false
    
    var onNavigateToWishWell: (() -> Void)?
    
    var totalWishCount: Int {
        todayWishes.count + previousWishes.count
    }
    
    var hasTodayWishes: Bool {
        !todayWishes.isEmpty
    }
    
    // MARK: - Init
    
    init() {
        fetchCouponHistory()
    }
    
    func fetchCouponHistory() {
        isLoading = true
        
        Task {
            do {
                let items: [CouponHistoryItem] = try await BaseService.shared.request(
                    endPoint: .fetchCouponHistory
                )
                
                let today = todayString()
                
                let todayItems = items.filter { $0.purchasedAt == today }
                let previousItems = items.filter { $0.purchasedAt != today }
                
                await MainActor.run {
                    self.todayWishes = todayItems.map { $0.toWishItem() }
                    self.previousWishes = previousItems.map { $0.toWishItem() }
                    self.isLoading = false
                }
            } catch {
                print("❌ 소원 이용내역 조회 실패: \(error)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Actions
    
    func navigateToMakeWish() {
        onNavigateToWishWell?()
    }
    
    // MARK: - Helper
    
    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: Date())
    }
}
