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
    case deleteChildDummy
    
    // Child
    case fetchChildren
    
    // Schedule
    case fetchSchedules(childId: Int, startDate: String, endDate: String)
    case postSchedule(childId: Int, request: AddScheduleRequestDTO)
    case fetchDefaultColor(childId: Int)
    case editSchedule(scheduleId: Int, selectedDate: String)
    case deleteSchedule(scheduleId: Int, selectedDate: String)
    
    // Mission
    case fetchMissions(childId: Int?)
    case updateMission(missionId: Int, request: WriteMissionRequestDTO)
    case deleteMission(missionId: Int)
    case postMission(childId: Int, request: WriteMissionRequestDTO)
    case postMissionSuggestions(request: MissionSuggestionRequestDTO)
    case postBulkMissions(childId: Int, request: MissionBulkCreateRequestDTO)
    
    // WishWell
    case fetchChildrenInfo
    case fetchWishes
    case purchaseCoupon(couponId: Int64)
    
    // Reward
    case fetchCoupons(childId: Int)
    case addCoupon(childId: Int)
    case deleteCoupon(couponId: Int)
    case updateCoupon(couponId: Int)
    
    //NotificationFeed
    case fetchFeeds(childId: Int64, size: Int?, cursor: String?)
    
    // CoinMission
    case completeMission(missionId: Int64)
    
    var refreshPolicy: TokenRefreshPolicy {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .reissueAccessToken, .reissueAllTokens:
            return .none
        case .fetchSchedules, .fetchChildrenInfo, .fetchWishes, .purchaseCoupon, .completeMission, .fireLit, .fetchJourneyList, .childSignup:
            return .child
        default:
            return .parent
        }
    }
    
    // DailyJourney
    case updateDailyJourney
    case skipJourney(scheduleDetailId: Int)
    case fetchJourneyList
    
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
            return "/api/v1/subscribe"
        case .sseToken:
            return "/api/v1/tokens/subscribe-token"
        case .childSignup:
            return "/api/v1/children/login"
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
        case .fetchCoupons(let childId), .addCoupon(let childId):
            return "/api/v1/coupons/\(childId)"
        case .deleteCoupon(let couponId), .updateCoupon(let couponId):
            return "/api/v1/coupons/\(couponId)"
        case .updateDailyJourney:
            return "/api/v1/schedules/today"
        case .skipJourney(let scheduleDetailId):
            return "/api/v1/schedules/skip/\(scheduleDetailId)"
        case .fetchJourneyList:
            return "/api/v1/schedules/progress"
        case .getPresignedURL:
            return "/api/v1/presigned-url/schedules"
        case .completeSchedule(let scheduleDetailId):
            return "/api/v1/schedules/verify/\(scheduleDetailId)"
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
        case .completeMission(let missionId):
            return "/api/v1/missions/\(missionId)/complete"
        case .deleteSchedule(let scheduleId, let selectedDate):
            return "/api/v1/schedules/\(scheduleId)?selectedDate=\(selectedDate)"
        case .editSchedule(let scheduleId, let selectedDate):
            return "/api/v1/schedules/\(scheduleId)?selectedDate=\(selectedDate)"
        case .updateMission(let missionId, _), .deleteMission(let missionId):
            return "/api/v1/missions/\(missionId)"
        }
    }
    
    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection, .fetchChildren, .fetchSchedules, .fetchChildrenInfo, .fetchWishes, .fetchMissions, .fetchDefaultColor, .fetchFeeds, .fetchJourneyList, .fetchCoupons:
            return "GET"
        case .updateDailyJourney, .skipJourney, .completeSchedule, .purchaseCoupon, .fireLit, .completeMission, .editSchedule, .updateMission, .updateCoupon:
            return "PATCH"
        case .deleteChildDummy, .deleteSchedule, .deleteMission, .deleteCoupon:
            return "DELETE"
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
