//
//  KakaoAuthService.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

import Combine

import KakaoSDKUser

final class KakaoAuthService: KakaoAuthServiceType {

    func loginWithKakao() async throws -> String {
        if UserApi.isKakaoTalkLoginAvailable() {
            return try await loginWithKakaoTalk()
        } else {
            return try await loginWithKakaoAccount()
        }
    }

    private func loginWithKakaoTalk() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let access = token?.accessToken, !access.isEmpty else {
                    continuation.resume(throwing: KakaoAuthError.emptyAccessToken)
                    return
                }
                continuation.resume(returning: access)
            }
        }
    }

    private func loginWithKakaoAccount() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                guard let access = token?.accessToken, !access.isEmpty else {
                    continuation.resume(throwing: KakaoAuthError.emptyAccessToken)
                    return
                }
                continuation.resume(returning: access)
            }
        }
    }
}

enum KakaoAuthError: Error {
    case emptyAccessToken
}
