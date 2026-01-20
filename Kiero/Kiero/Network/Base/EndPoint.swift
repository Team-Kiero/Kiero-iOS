//
//  EndPoint.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

enum EndPoint {
    // Invite Code
    case postInviteCode
    case checkConnection
    case subscribeConnection
    
    // Login
    case childSignup
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
    
    // AddSchedule
    case postSchedule(childId: Int, request: AddScheduleRequestDTO)
    
    // Mission
    case fetchMissions(childId: Int?)
    
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
        }
    }
    
    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection,
                .fetchChildren, .fetchSchedules, .fetchMissions:
            return "GET"
        case .postSchedule:
            return "POST"
        default:
            return "POST"
        }
    }
    
    var header: [String: String] {
        switch self {
        case .kakaoLogin, .kakaoAccessToken, .childSignup:
            return HeaderType.none.type
        default:
            return HeaderType.auth.type
        }
    }
}
