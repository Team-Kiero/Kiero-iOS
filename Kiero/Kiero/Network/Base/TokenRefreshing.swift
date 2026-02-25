//
//  TokenRefreshing.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

protocol TokenRefreshing {
    func refreshAccessToken() async throws
    func refreshAllTokens() async throws
    func reissueSseAccessToken() async throws -> String
}
