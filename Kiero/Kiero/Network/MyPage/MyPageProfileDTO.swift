//
//  MyPageProfileDTO.swift
//  Kiero
//
//  Created by 안치욱 on 5/31/26.
//

import Foundation

struct MyPageProfileDTO: Codable {
    let id: Int
    let image: String?
    let name: String
    let hasPendingChildSession: Bool
    let pushNotificationEnabled: Bool
}
