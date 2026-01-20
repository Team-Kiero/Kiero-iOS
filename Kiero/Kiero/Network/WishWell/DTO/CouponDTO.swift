//
//  CouponDTO.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Foundation

struct CouponResponseDTO: Decodable {
    let id: Int64
    let name: String
    let price: Int
}

struct Coupon: Decodable {
    let id: Int64
    let name: String
    let price: Int
}

extension CouponResponseDTO {
    func toEntity() -> Coupon {
        .init(id: id, name: name, price: price)
    }
}
