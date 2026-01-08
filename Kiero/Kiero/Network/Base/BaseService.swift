//
//  BaseService.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

final class BaseService {
    static let shared = BaseService()
    private init() { }
    
    func request<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable? = nil
    ) async throws -> Response {
        // URL 구성
        let urlString = Config.baseURL + endPoint.url
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }
        
        // Request 준비
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method
        endPoint.header.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Body가 있다면 JSON 인코딩
        if let body = body {
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        // network 호출
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        NetworkLogger.shared.responseLog(httpResponse, data: data)
        
        // 상태 코드 체크
        let statusCode = httpResponse.statusCode
        
        if (400...499).contains(statusCode) {
            throw NetworkError.clientError(statusCode: statusCode)
        } else if (500...599).contains(statusCode) {
            throw NetworkError.internalServerError
        } else if !(200...299).contains(statusCode) {
            throw NetworkError.unknownError
        }
        
        // 디코딩
        do {
            // 응답 데이터가 없는(EmptyResponse) 경우 처리
            if Response.self == EmptyResponse.self {
                let decoded = try JSONDecoder().decode(BaseResponse<EmptyResponse>.self, from: data)
                return decoded as! Response
            }
            
            let decoded = try JSONDecoder().decode(BaseResponse<Response>.self, from: data)
            
            guard let data = decoded.data else {
                throw NetworkError.noData
            }
            
            return data
        } catch {
            throw NetworkError.responseDecodingError
        }
    }
}
