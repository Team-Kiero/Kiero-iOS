//
//  GiveFireStoneDTO.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/22/26.
//

import Foundation

//struct GiveFireStoneDTO: Decodable {
//    let status: Int
//    let message: String
//    let data: FireLitData?
//}

struct FireLitData: Decodable {
    let gotStones: [String] // 용인지
    let earnedCoinAmount: Int
}
