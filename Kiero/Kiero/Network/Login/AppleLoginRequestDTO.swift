//
//  AppleLoginRequestDTO.swift
//  Kiero
//
//  Created by 신혜연 on 5/25/26.
//

struct AppleLoginRequestDTO: Encodable {
    let identityToken: String
    let authorizationCode: String
    let name: String?
}
