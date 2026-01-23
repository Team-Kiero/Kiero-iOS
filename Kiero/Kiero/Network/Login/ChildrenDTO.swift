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

struct ChildRegistrationStatusDTO: Codable {
    let isRegistered: Bool
    let childId: Int?
}

struct ChildrenData: Decodable {
    let childId: Int
    let childLastName: String
    let childFirstName: String
}

typealias ChildListResponse = [ChildrenData]
