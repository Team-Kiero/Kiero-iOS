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
    let userName: String = "근영"
    var currentCoinCount: Int = 350
    
    func fetchWishList(completion: @escaping () -> Void) {
        self.wishList = [
            Wish(name: "게임시간 30분 추가", price: 100),
            Wish(name: "용돈 5,000원 받기", price: 50),
            Wish(name: "야구장 직관가기", price: 100),
            Wish(name: "저녁으로 치킨 먹기", price: 100),
            Wish(name: "테스트 소원 1", price: 10),
            Wish(name: "테스트 소원 2", price: 20),
            Wish(name: "테스트 소원 3", price: 30),
            Wish(name: "테스트 소원 4", price: 40),
            Wish(name: "데이식스 콘서트 가기", price: 350),
            Wish(name: "집에 가고 싶다", price: 40)
        ]
        completion()
    }
}
