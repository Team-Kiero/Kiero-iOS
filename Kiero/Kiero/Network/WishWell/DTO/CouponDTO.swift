//
//  CouponDTO.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Foundation

struct CouponResponseDTO: Decodable {
    let couponId: Int64
    let name: String
    let price: Int
}

struct Coupon: Decodable {
    let id: Int64
    let name: String
    let price: Int
}

struct CouponSseEventPayload: Decodable {
    let eventType: String
    let couponName: String?
    let price: Int?
}

extension CouponResponseDTO {
    func toEntity() -> Coupon {
        .init(id: couponId, name: name, price: price)
    }
}

// MARK: - 소원 이용내역

struct CouponHistoryItem: Decodable {
    let name: String
    let price: Int
    let purchasedAt: String
}

struct WishItem: Identifiable {
    let id: String
    let title: String
    let acquiredDate: String
    let cost: Int
}

extension CouponHistoryItem {
    func toWishItem() -> WishItem {
        let displayDate = formatDate(purchasedAt)
        return WishItem(
            id: name + purchasedAt + String(price),
            title: name,
            acquiredDate: displayDate,
            cost: price
        )
    }
    
    private func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = inputFormatter.date(from: dateString) else { return dateString }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "M월 d일"
        outputFormatter.locale = Locale(identifier: "ko_KR")
        
        return outputFormatter.string(from: date)
    }
}
