//
//  ChildLoginDTO.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

struct ChildLoginRequest: Encodable {
    let lastName: String
    let firstName: String
    let inviteCode: String
}

struct ChildLoginData: Decodable {
    let id: Int
    let lastName: String
    let firstName: String
    let role: String
    let accessToken: String
    let refreshToken: String
}

struct ChildRegistrationStatusDTO: Codable {
    let isRegistered: Bool
    let childId: Int?
}

struct ChildData: Decodable {
    let id: Int
    let childId: Int
    let childLastName: String
    let childFirstName: String
}

typealias ChildListResponse = [ChildData]
