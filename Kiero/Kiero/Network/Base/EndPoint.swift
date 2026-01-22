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
    case deleteChildDummy
    
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
    
    // CoinMission
    case fetchChildrenInfo
    case fetchWishes
    case purchaseCoupon(couponId: Int64)
    
    //NotificationFeed
    case fetchFeeds(childId: Int64, size: Int?, cursor: String?)
    
    var refreshPolicy: TokenRefreshPolicy {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .childSignup, .reissueAccessToken, .reissueAllTokens:
            return .none
        case .fetchSchedules, .fetchChildrenInfo, .fetchWishes, .purchaseCoupon, .fireLit:
            return .child
        default:
            return .parent
        }
    }
    
    // DailyJourney
    case updateDailyJourney
    case skipJourney(scheduleDetailId: Int)
    
    // Presigned URL 요청
    case getPresignedURL
    
    // MissionComplete
    case completeSchedule(scheduleDetailId: Int)
    
    // GiveFireStone
    case fireLit
    
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
        case .updateDailyJourney:
            return "/api/v1/schedules/today"
        case .skipJourney(let scheduleDetailId):
            return "/api/v1/schedules/skip/\(scheduleDetailId)"
        case .getPresignedURL:
            return "/api/v1/presigned-url/schedules"
        case .completeSchedule(let scheduleDetailId):
            return "/api/v1/schedules/\(scheduleDetailId)"
        case .fireLit:
            return "/api/v1/schedules/fire-lit"
        case .fetchDefaultColor(let childId):
            return "/api/v1/schedules/\(childId)/default"
        case .deleteChildDummy:
            return "/api/v1/dummy"
        case .fetchFeeds(let childId, let size, let cursor):
            var query: [String] = []
            if let size { query.append("size=\(size)") }
            if let cursor, !cursor.isEmpty { query.append("cursor=\(cursor)") }
            let queryString = query.isEmpty ? "" : "?\(query.joined(separator: "&"))"
            return "/api/v1/feeds/\(childId)\(queryString)"
        }
    }
    
    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection, .fetchChildren, .fetchSchedules, .fetchChildrenInfo, .fetchWishes, .fetchMissions, .fetchDefaultColor, .fetchFeeds:
            return "GET"
        case .updateDailyJourney, .skipJourney, .completeSchedule, .purchaseCoupon, .fireLit:
            return "PATCH"
        case .deleteChildDummy:
            return "DELETE"
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
