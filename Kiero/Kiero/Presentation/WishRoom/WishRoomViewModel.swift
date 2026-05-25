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
    
    var onNavigateToWishWell: (() -> Void)?
    
    var totalWishCount: Int {
        todayWishes.count + previousWishes.count
    }
    
    var hasTodayWishes: Bool {
        !todayWishes.isEmpty
    }
    
    // MARK: - Init
    
    init() {
        loadMockData()
    }
    
    // MARK: - Mock Data
    
    // TODO: - Api 연결 후 삭제
    
    private func loadMockData() {
        todayWishes = [
            WishItem(id: 1, title: "상헌 아트디렉터되기", acquiredDate: "5월 10일", cost: 100),
            WishItem(id: 2, title: "윤주 데이트하기", acquiredDate: "5월 10일", cost: 100)
        ]
        
        previousWishes = [
            WishItem(id: 3, title: "키어로 여름엠티", acquiredDate: "5월 2일", cost: 100),
            WishItem(id: 4, title: "포이 숭실대오기", acquiredDate: "5월 2일", cost: 100),
            WishItem(id: 5, title: "그냥이 건물공동소유", acquiredDate: "5월 2일", cost: 100),
            WishItem(id: 6, title: "윤주 영화보기", acquiredDate: "5월 2일", cost: 100)
        ]
    }
    
    // MARK: - Actions
    
    func navigateToMakeWish() {
        onNavigateToWishWell?()
    }
}
