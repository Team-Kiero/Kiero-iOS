//
//  HeaderType.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

enum HeaderType {
    case none
    case auth
    case refreshCookie
    case sseSubscribe

    var type: [String: String] {
        switch self {
        case .none:
            return ["Content-Type": "application/json"]

        case .auth:
            let token = TokenManager.shared.getAccessToken() ?? ""
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(token)"
            ]

        case .refreshCookie:
            let refresh = TokenManager.shared.getRefreshToken() ?? ""
            return [
                "Content-Type": "application/json",
                "Cookie": "refreshToken=\(refresh)"
            ]
            
        case .sseSubscribe:
            let sseToken = TokenManager.shared.getSseToken() ?? ""
            return [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(sseToken)"
            ]
        }
    }
}
