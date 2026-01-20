//
//  InviteCodeDTO.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

struct InviteCodeRequest: Encodable {
    let childLastName: String
    let childFirstName: String
}

struct InviteCodeData: Decodable {
    let code: String
    let childLastName: String
    let childFirstName: String
}
