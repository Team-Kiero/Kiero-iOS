//
//  AuthAPI.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

import Foundation

import Moya

enum AuthAPI {
    case kakaoLogin(authCode: String)
    case kakaoAccessToken(token: String)
    case getProfile
    case logout
    case reissueAccessToken
    case reissueAllTokens
}

extension AuthAPI: TargetType {
    var baseURL: URL { Config.apiBaseURL }

    var path: String {
        switch self {
        case .kakaoLogin: return "/api/v1/parents/login"
        case .kakaoAccessToken: return "/api/v1/parents/login/access-token"
        case .getProfile: return "/api/v1/parents/profile"
        case .logout: return "/api/v1/tokens/logout"
        case .reissueAccessToken: return "/api/v1/tokens/reissue/access-token"
        case .reissueAllTokens: return "/api/v1/tokens/reissue/tokens"
        }
    }

    var method: Moya.Method {
        switch self {
        case .getProfile: return .get
        default: return .post
        }
    }

    var task: Task {
        switch self {
        case .kakaoLogin(let authCode):
            return .requestParameters(
                parameters: ["authCode": authCode],
                encoding: URLEncoding.queryString
            )

        case .kakaoAccessToken(let token):
            return .requestParameters(
                parameters: ["accessToken": token],
                encoding: URLEncoding.queryString
            )

        case .reissueAccessToken, .reissueAllTokens:
            return .requestPlain

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
}
