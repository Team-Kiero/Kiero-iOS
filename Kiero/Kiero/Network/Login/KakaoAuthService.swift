//
//  KakaoAuthService.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

import Combine
import Foundation

import KakaoSDKAuth
import KakaoSDKUser

enum KakaoLoginError: Error {
    case cancelled
    case unknown(Error)
}

enum KakaoAuthError: Error {
    case emptyAccessToken
}

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
                    continuation.resume(throwing: self.mapKakaoError(error))
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
                    continuation.resume(throwing: self.mapKakaoError(error))
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
    
    // MARK: - Error Mapping
    
    private func mapKakaoError(_ error: Error) -> Error {
        if isCancelled(error) {
            return KakaoLoginError.cancelled
        }
        return KakaoLoginError.unknown(error)
    }
    
    private func isCancelled(_ error: Error) -> Bool {
        let ns = error as NSError
        
        if ns.domain == NSURLErrorDomain,
           ns.code == NSURLErrorCancelled {
            return true
        }
        
        if let cause = ns.userInfo["AuthErrorCause"] as? String,
           cause.lowercased().contains("cancel") {
            return true
        }
        
        return false
    }
}
