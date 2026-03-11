//
//  WriteMissionDTO.swift
//  Kiero
//
//  Created by 신혜연 on 1/21/26.
//

import Foundation

struct WriteMissionRequestDTO: Encodable {
    let name: String
    let reward: Int
    let dueAt: String
}

struct WriteMissionResponseDTO: Decodable {
    let id: Int
    let name: String
    let reward: Int
    let dueAt: String
}
