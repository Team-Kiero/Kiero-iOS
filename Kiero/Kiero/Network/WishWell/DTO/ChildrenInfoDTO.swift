//
//  ChildrenInfoDTO.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Foundation

struct ChildrenInfoResponseDTO: Decodable {
    let firstName: String
    let lastName: String
    let coinAmount: Int
    let today: String
}

struct ChildrenInfo {
    let firstName: String
    let coinAmount: Int
    let today: String
}

extension ChildrenInfoResponseDTO {
    func toEntity() -> ChildrenInfo {
        .init(
            firstName: firstName,
            coinAmount: coinAmount,
            today: today
        )
    }
}
