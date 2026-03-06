//
//  RewardResponseDTO.swift
//  Kiero
//
//  Created by 정윤아 on 3/7/26.
//

import Foundation

struct RewardResponseDTO: Decodable {
    let couponId: Int
    let name: String
    let price: Int
    
    func toEntity() -> Reward {
        return Reward(
            id: couponId,
            title: name,
            cost: price
        )
    }
}
