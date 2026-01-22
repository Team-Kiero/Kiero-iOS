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
    case checkConnection(lastName: String, firstName: String)
    case subscribeConnection
    
    // Login
    case childSignup(lastName: String, firstName: String, inviteCode: String)
    case kakaoLogin(authCode: String)
    case kakaoAccessToken(token: String)
    
    // Logout & Token
    case logout
    case reissueAccessToken
    case reissueAllTokens
    case sseToken
    
    // Child
    case fetchChildren

    // Schedule
    case fetchSchedules(childId: Int, startDate: String, endDate: String)
    
    // AddSchedule
    case postSchedule(childId: Int, request: AddScheduleRequestDTO)
    case fetchDefaultColor(childId: Int)
    
    // Mission
    case fetchMissions(childId: Int?)
    
    // WriteMission
    case postMission(childId: Int, request: WriteMissionRequestDTO)
    
    // AIMission
    case postMissionSuggestions(request: MissionSuggestionRequestDTO)
    case postBulkMissions(childId: Int, request: MissionBulkCreateRequestDTO)
    
    //CoinMission
    case fetchChildrenInfo
    case fetchWishes
    case purchaseCoupon(couponId: Int64)
    
    var refreshPolicy: TokenRefreshPolicy {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .childSignup, .reissueAccessToken, .reissueAllTokens:
            return .none
        case .fetchSchedules, .fetchChildrenInfo, .fetchWishes, .purchaseCoupon:
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
            return "/api/v1/subscribe"
        case .sseToken:
            return "/api/v1/tokens/subscribe-token"
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
        case .postSchedule(let childId, _):
            return "/api/v1/schedules/\(childId)"
        case .fetchMissions(let childId):
            var path = "/api/v1/missions"
            if let id = childId {
                path += "?childId=\(id)"
            }
            return path
        case .postMission(let childId, _):
            return "/api/v1/missions/\(childId)"
        case .postMissionSuggestions:
            return "/api/v1/missions/suggestions"
        case .postBulkMissions(let childId, _):
            return "/api/v1/missions/\(childId)/bulk"
        case .fetchChildrenInfo:
            return "/api/v1/children/me"
        case .fetchWishes:
            return "/api/v1/coupons"
        case .purchaseCoupon(let couponId):
            return "/api/v1/coupons/\(couponId)"
        case .fetchDefaultColor(let childId):
            return "/api/v1/schedules/\(childId)/default"
        }
    }
    
    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection, .fetchChildren, .fetchSchedules, .fetchChildrenInfo, .fetchWishes, .fetchMissions, .fetchDefaultColor:
            return "GET"
        case .purchaseCoupon:
            return "PATCH"
        default:
            return "POST"
        }
    }
    
    var header: [String: String] {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .childSignup, .reissueAllTokens, .reissueAccessToken:
            return HeaderType.none.type
        case .sseToken:
            return HeaderType.sseSubscribe.type
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
        case .checkConnection(let lastName, let firstName):
            return [
                URLQueryItem(name: "childLastName", value: lastName),
                URLQueryItem(name: "childFirstName", value: firstName)
            ]
        default:
            return nil
        }
    }
}
