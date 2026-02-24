//
//  ResponseDecoder.swift
//  Kiero
//
//  Created by 신혜연 on 2/24/26.
//

import Foundation

struct ResponseDecoder {
    
    static func decode<Response: Decodable>(
        data: Data,
        statusCode: Int
    ) throws -> Response {
        
        if statusCode == 401 {
            throw NetworkError.clientError(statusCode: 401)
        }

        if (400...499).contains(statusCode) {
            if let message = try? JSONDecoder().decode(ErrorResponse.self, from: data).message {
                throw NetworkError.codeError(message)
            } else {
                throw NetworkError.clientError(statusCode: statusCode)
            }
        }
        
        if (500...599).contains(statusCode) {
            throw NetworkError.internalServerError
        }
        
        guard (200...299).contains(statusCode) else {
            throw NetworkError.unknownError
        }
        
        if data.isEmpty {
            if Response.self == EmptyResponse.self {
                return EmptyResponse() as! Response
            }
            throw NetworkError.noData
        }
        
        if Response.self == EmptyResponse.self {
            return EmptyResponse() as! Response
        }
        
        let decoded = try JSONDecoder().decode(BaseResponse<Response>.self, from: data)
        
        guard let result = decoded.data else {
            throw NetworkError.noData
        }
        
        return result
    }
}
