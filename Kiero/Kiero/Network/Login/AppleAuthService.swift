//
//  AppleAuthService.swift
//  Kiero
//
//  Created by 신혜연 on 5/24/26.
//

import AuthenticationServices
import Combine
import Foundation

enum AppleLoginError: Error {
    case cancelled
    case missingCredential
    case invalidToken
    case unknown(Error)
}

final class AppleAuthService: NSObject, AppleAuthServiceType {

    private var continuation: CheckedContinuation<AppleLoginCredential, Error>?

    func loginWithApple() async throws -> AppleLoginCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let request = ASAuthorizationAppleIDProvider().createRequest()
            request.requestedScopes = [.fullName, .email]

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self
            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthService: ASAuthorizationControllerDelegate {

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            continuation?.resume(throwing: AppleLoginError.missingCredential)
            continuation = nil
            return
        }

        guard
            let identityTokenData = credential.identityToken,
            let identityToken = String(data: identityTokenData, encoding: .utf8),
            let authCodeData = credential.authorizationCode,
            let authorizationCode = String(data: authCodeData, encoding: .utf8)
        else {
            continuation?.resume(throwing: AppleLoginError.invalidToken)
            continuation = nil
            return
        }

        let name: String? = {
            guard let nameComponents = credential.fullName else { return nil }
            let full = [nameComponents.familyName, nameComponents.givenName]
                .compactMap { $0 }
                .joined()
            return full.isEmpty ? nil : full
        }()

        let result = AppleLoginCredential(
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            name: name
        )
        print("✅ identityToken:", identityToken)
        print("✅ authorizationCode:", authorizationCode)
        print("✅ name:", name ?? "nil")
        
        continuation?.resume(returning: result)
        continuation = nil
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if let authError = error as? ASAuthorizationError,
           authError.code == .canceled {
            continuation?.resume(throwing: AppleLoginError.cancelled)
        } else {
            continuation?.resume(throwing: AppleLoginError.unknown(error))
        }
        continuation = nil
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?
            .keyWindow ?? UIWindow()
    }
}
