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
    
    //CoinMission
    case fetchChildrenInfo
    case fetchWishes
    case purchaseCoupon(couponId: Int64)
    
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
    
    // 인증 완료 요청
    case completeSchedule(scheduleDetailId: Int) // 바디는 서비스에서 넘겨줌
    
    // 불 피우기
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
        }
    }
    
    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection, .fetchChildren, .fetchSchedules, .fetchChildrenInfo, .fetchWishes:
            return "GET"
        case .updateDailyJourney, .skipJourney, .completeSchedule, .purchaseCoupon, .fireLit:
            return "PATCH"
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
