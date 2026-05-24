//
//  AppleLoginCredential.swift
//  Kiero
//
//  Created by 신혜연 on 5/24/26.
//

struct AppleLoginCredential {
    let identityToken: String
    let authorizationCode: String
    let name: String?
}

protocol AppleAuthServiceType {
    func loginWithApple() async throws -> AppleLoginCredential
}
