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
    case codeError(String)
    
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
        case .codeError:
            return "코드 에러"
        }
    }
    
    var toastMessage: String {
        switch self {
        case .invalidURL, .unknownError:
            return "네트워크 연결 상태를 확인해주세요."
        case .internalServerError:
            return "일시적인 오류입니다. 잠시 후 다시 시도해주세요."
        case .responseDecodingError, .noData:
            return "일시적인 오류입니다. 잠시 후 다시 시도해주세요."
        case .clientError:
            return "요청에 실패했어요. 다시 시도해주세요."
        case .codeError(let message):
            return message
        }
    }
}
