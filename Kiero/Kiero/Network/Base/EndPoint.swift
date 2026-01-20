//
//  EndPoint.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

enum TokenRefreshPolicy {
    case none
    case parent
    case child
}

enum EndPoint {
    // Invite Code
    case postInviteCode
    case checkConnection
    case subscribeConnection
    
    // Login
    case childSignup(lastName: String, firstName: String, inviteCode: String)
    case kakaoLogin(authCode: String)
    case kakaoAccessToken(token: String)
    
    // Logout & Token
    case logout
    case reissueAccessToken
    case reissueAllTokens
    
    // Child
    case fetchChildren

    // Schedule
    case fetchSchedules(childId: Int, startDate: String, endDate: String)
    
    var refreshPolicy: TokenRefreshPolicy {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .childSignup, .reissueAccessToken, .reissueAllTokens:
            return .none
        case .fetchSchedules:
            return .child
        default:
            return .parent
        }
    }
    
    var url: String {
        switch self {
        case .postInviteCode, .checkConnection:
            return "/api/v1/parents/invite"
        case .subscribeConnection:
            return "/api/v1/parents/invite/subscribe"
        case .childSignup:
            return "/api/v1/children/signup"
        case .fetchChildren:
            return "/api/v1/parents/children"
        case .kakaoLogin:
            return "/api/v1/parents/login"
        case .kakaoAccessToken:
            return "/api/v1/parents/login/access-token"
        case .logout:
            return "/api/v1/tokens/logout"
        case .reissueAccessToken:
            return "/api/v1/tokens/reissue/access-token"
        case .reissueAllTokens:
            return "/api/v1/tokens/reissue/tokens"
        case .fetchSchedules(let childId, let start, let end):
            return "/api/v1/schedules/\(childId)?startDate=\(start)&endDate=\(end)"
        }
    }

    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection, .fetchChildren, .fetchSchedules:
            return "GET"
        default:
            return "POST"
        }
    }

    var header: [String: String] {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .childSignup, .reissueAllTokens, .reissueAccessToken:
            return HeaderType.none.type
        default:
            return HeaderType.auth.type
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .kakaoAccessToken(let token):
            return [URLQueryItem(name: "accessToken", value: token)]
        case .kakaoLogin(let authCode):
            return [URLQueryItem(name: "authCode", value: authCode)]
        default:
            return nil
        }
    }
}
