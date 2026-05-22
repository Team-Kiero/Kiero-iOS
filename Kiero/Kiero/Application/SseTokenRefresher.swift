//
//  SseTokenRefresher.swift
//  Kiero
//
//  Created by 안치욱 on 5/19/26.
//

import Foundation

protocol SseTokenRefresherType {
    func reissueSseAccessToken() async throws -> String
}

final class SseTokenRefresher: SseTokenRefresherType {
    
    func reissueSseAccessToken() async throws -> String {
        try await TokenRefresher.shared.reissueSseAccessToken()
    }
}
