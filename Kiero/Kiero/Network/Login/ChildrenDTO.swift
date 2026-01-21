//
//  ChildrenDTO.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

struct ChildSignupRequest: Encodable {
    let lastName: String
    let firstName: String
    let inviteCode: String
}

struct ChildSignupData: Decodable {
    let lastName: String
    let firstName: String
    let role: String
    let accessToken: String
    let refreshToken: String
}
