//
//  HeaderType.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

enum HeaderType {
    case none
    case auth
    
    var type: [String: String] {
        switch self {
        case .none:
            return ["Content-Type": "application/json"]
        case .auth:
            return [
                "Content-Type": "application/json",
                // TODO: 인증이 필요한 API의 경우 추가
            ]
        }
    }
}
