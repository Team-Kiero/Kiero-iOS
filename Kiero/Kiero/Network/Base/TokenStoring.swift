//
//  TokenStoring.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

protocol TokenStoring {
    func getRefreshToken() -> String?
    func saveAccessToken(_ token: String)
    func saveRefreshToken(_ token: String)
    func saveSseToken(_ token: String)
    func clearTokens()
    func clearAll()
}

extension TokenManager: TokenStoring {}
