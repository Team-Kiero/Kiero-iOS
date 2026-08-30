//
//  ParentLoginDTO.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

struct ParentLoginData: Codable {
    let id: Int
    let name: String
    let email: String
    let image: String?
    let role: String
    let accessToken: String
    let refreshToken: String
}
