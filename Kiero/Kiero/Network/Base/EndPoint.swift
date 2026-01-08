//
//  EndPoint.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

enum EndPoint {
    // 1. 초대 관련
    case postInviteCode               // 초대코드 발급
    case checkConnection              // 아이 연동여부 조회
    case subscribeConnection          // 아이 연동여부 실시간 수신 (SSE)
    
    // 2. 회원가입 및 로그인
    case childSignup                  // 아이 회원가입
    case kakaoLogin(authCode: String)  // 카카오로그인 (authCode)
    case kakaoAccessToken(token: String) // 카카오로그인 (accessToken)
    
    // 3. 토큰 및 계정
    case logout                       // 로그아웃
    case reissueAccessToken           // access token 재발급
    case reissueAllTokens             // 모든 토큰 재발급
    
    // 4. 자녀 관리
    case fetchChildren                // 자녀 목록 조회

    var url: String {
        switch self {
        // 초대 및 자녀
        case .postInviteCode, .checkConnection:
            return "/api/v1/parents/invite"
        case .subscribeConnection:
            return "/api/v1/parents/invite/subscribe"
        case .childSignup:
            return "/api/v1/children/signup"
        case .fetchChildren:
            return "/api/v1/parents/children"
            
        // 인증 및 토큰
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
        }
    }

    var method: String {
        switch self {
        case .checkConnection, .subscribeConnection, .fetchChildren:
            return "GET"
        default:
            return "POST"
        }
    }

    var header: [String: String] {
        switch self {
        // 인증이 필요 없는 API (로그인, 회원가입 등)
        case .kakaoLogin, .kakaoAccessToken, .childSignup:
            return HeaderType.none.type
        // 그 외 인증이 필요한 API
        default:
            return HeaderType.auth.type
        }
    }
}
