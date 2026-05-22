//
//  AuthService.swift
//  Kiero
//
//  Created by 안치욱 on 5/18/26.
//

import Foundation

protocol AuthServiceType {
    func parentLogin() async throws -> LoginData

    func childSignup(
        lastName: String,
        firstName: String,
        inviteCode: String
    ) async throws -> ChildSignupData

    func fetchChildren() async throws -> ChildListResponse
}

final class AuthService: AuthServiceType {

    private let kakaoAuthService: KakaoAuthServiceType

    init(kakaoAuthService: KakaoAuthServiceType) {
        self.kakaoAuthService = kakaoAuthService
    }

    func parentLogin() async throws -> LoginData {
        let kakaoToken = try await kakaoAuthService.loginWithKakao()

        return try await BaseService.shared.request(
            endPoint: .kakaoAccessToken(token: kakaoToken)
        )
    }

    func childSignup(
        lastName: String,
        firstName: String,
        inviteCode: String
    ) async throws -> ChildSignupData {
        let body = ChildSignupRequest(
            lastName: lastName,
            firstName: firstName,
            inviteCode: inviteCode
        )

        return try await BaseService.shared.request(
            endPoint: .childSignup(
                lastName: lastName,
                firstName: firstName,
                inviteCode: inviteCode
            ),
            body: body
        )
    }

    func fetchChildren() async throws -> ChildListResponse {
        try await BaseService.shared.request(
            endPoint: .fetchChildren
        )
    }
}
