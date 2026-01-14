//
//  WishWellViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 1/12/26.
//

// MARK: - Model

struct Wish: Codable {
    let name: String
    let price: Int
}

// MARK: - ViewModel

final class WishWellViewModel: BaseViewModel {

    private(set) var wishList: [Wish] = []
    let userName: String = "윤아"
    var currentCoinCount: Int = 350
    
    func fetchWishList(completion: @escaping () -> Void) {
        self.wishList = [
            Wish(name: "게임시간 30분 추가", price: 100),
            Wish(name: "용돈 5,000원 받기", price: 50),
            Wish(name: "야구장 직관가기", price: 100),
            Wish(name: "저녁으로 치킨 먹기", price: 100),
            Wish(name: "데이식스 팬싸인회 가기", price: 100),
            Wish(name: "데이식스 콘서트 가기", price: 350),
            Wish(name: "박성찐이야 보기", price: 20),
            Wish(name: "행복 앱잼하기", price: 30),
            Wish(name: "아요랑 맛있는거 먹기", price: 40),
            Wish(name: "집에 가고 싶다", price: 40)
        ]
        completion()
    }
    
    func purchaseCoin(price: Int) {
        self.currentCoinCount -= price 
    }
}
