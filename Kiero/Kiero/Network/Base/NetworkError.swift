//
//  NetworkError.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case responseDecodingError
    case noData
    case unknownError
    case internalServerError
    case clientError(statusCode: Int)
    
    var errorDescription: String {
        switch self {
        case .invalidURL:
            return "잘못된 URL"
        case .responseDecodingError:
            return "디코딩 에러"
        case .noData:
            return "데이터 없음"
        case .unknownError:
            return "알 수 없는 에러"
        case .internalServerError:
            return "서버 에러"
        case .clientError(let code):
            return "클라이언트 요청 에러 (Code: \(code))"
        }
    }
}
