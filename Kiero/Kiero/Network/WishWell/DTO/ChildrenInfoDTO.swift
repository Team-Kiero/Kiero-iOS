//
//  ChildrenInfoDTO.swift
//  Kiero
//
//  Created by 정윤아 on 1/21/26.
//

import Foundation

struct ChildrenInfoResponseDTO: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let coinAmount: Int
    let today: String
    let pushNotificationEnabled: Bool?
}

struct ChildrenInfo {
    let firstName: String
    let coinAmount: Int
    let today: String
    let pushNotificationEnabled: Bool
}

extension ChildrenInfoResponseDTO {
    func toEntity() -> ChildrenInfo {
        .init(
            firstName: firstName,
            coinAmount: coinAmount,
            today: today,
            pushNotificationEnabled: pushNotificationEnabled ?? false
        )
    }
}
