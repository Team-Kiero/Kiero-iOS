//
//  BaseService.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ value: Encodable) {
        self.encodeFunc = value.encode
    }
    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}

final class BaseService {
    static let shared = BaseService()
    private init() { }
    
    func request<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable? = nil,
        didRetry: Bool = false
    ) async throws -> Response {
        
        do {
            return try await perform(endPoint: endPoint, body: body)
        } catch let error as NetworkError {
            
            guard case .clientError(let statusCode) = error, statusCode == 401, didRetry == false else {
                throw error
            }
            
            switch endPoint.refreshPolicy {
            case .none:
                throw error
                
            case .child:
                // 자녀: 항상 allTokens
                try await refreshAllTokens()
                return try await request(endPoint: endPoint, body: body, didRetry: true)
                
            case .parent:
                // 부모: accessOnly 먼저 → 실패하면 allTokens
                do {
                    try await refreshAccessToken()
                } catch {
                    // accessOnly 재발급 실패 = refresh 만료 가능성 → allTokens 시도
                    try await refreshAllTokens()
                }
                return try await request(endPoint: endPoint, body: body, didRetry: true)
            }
        }
    }
    
    private func perform<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable?
    ) async throws -> Response {
        
        // URL 구성
        let urlString = Config.baseURL + endPoint.url
        guard var components = URLComponents(string: urlString) else {
            throw NetworkError.invalidURL
        }
        if let items = endPoint.queryItems, !items.isEmpty {
            components.queryItems = items
        }
        guard let url = components.url else {
            throw NetworkError.invalidURL
        }
        
        // Request 준비
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method
        request.timeoutInterval = 5.0
        endPoint.header.forEach { key, value in
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Body가 있다면 JSON 인코딩
        if let body = body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        
        // Network 호출
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
        
        // Empty Body 대응 (데이터가 아예 없는 경우)
        if data.isEmpty {
            if Response.self == EmptyResponse.self {
                return EmptyResponse() as! Response
            } else {
                throw NetworkError.noData
            }
        }
        
        //  디코딩
        do {
            if Response.self == EmptyResponse.self {
                return EmptyResponse() as! Response
            }
            
            let decoded = try JSONDecoder().decode(BaseResponse<Response>.self, from: data)
            
            if let data = decoded.data {
                return data
            }
            else if Response.self == EmptyResponse.self {
                return EmptyResponse() as! Response
            }
            else if let nilValue = (decoded.data as Any?) as? Response {
                return nilValue
            }
            else {
                throw NetworkError.noData
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            if Response.self == EmptyResponse.self {
                return EmptyResponse() as! Response
            }
            print("❌ Decoding Error 상세: \(error)")
            throw NetworkError.responseDecodingError
        }
    }
    
    // accessToken 재발급
    private func refreshAccessToken() async throws {
        guard let refresh = TokenManager.shared.getRefreshToken(), !refresh.isEmpty else {
            TokenManager.shared.clearTokens()
            throw NetworkError.clientError(statusCode: 401)
        }
        
        let urlString = Config.baseURL + EndPoint.reissueAccessToken.url
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("refreshToken=\(refresh)", forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.unknownError }
        
        NetworkLogger.shared.responseLog(http, data: data)
        
        guard (200...299).contains(http.statusCode) else {
            TokenManager.shared.clearAll()
            throw NetworkError.clientError(statusCode: http.statusCode)
        }
        
        //  응답에서 accessToken 추출
        do {
            let decoded = try JSONDecoder().decode(BaseResponse<AccessTokenData>.self, from: data)
            guard let tokenData = decoded.data else { throw NetworkError.noData }
            TokenManager.shared.saveAccessToken(tokenData.accessToken)
        } catch {
            throw NetworkError.responseDecodingError
        }
    }
    
    private func refreshAllTokens() async throws {
        guard let refresh = TokenManager.shared.getRefreshToken(), !refresh.isEmpty else {
            TokenManager.shared.clearAll()
            throw NetworkError.clientError(statusCode: 401)
        }
        
        let urlString = Config.baseURL + EndPoint.reissueAllTokens.url
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("refreshToken=\(refresh)", forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.unknownError }
        
        NetworkLogger.shared.responseLog(http, data: data)
        
        guard (200...299).contains(http.statusCode) else {
            TokenManager.shared.clearAll()
            throw NetworkError.clientError(statusCode: http.statusCode)
        }
        
        do {
            let decoded = try JSONDecoder().decode(BaseResponse<AccessTokenData>.self, from: data)
            guard let tokenData = decoded.data else { throw NetworkError.noData }
            TokenManager.shared.saveAccessToken(tokenData.accessToken)
        } catch {
            throw NetworkError.responseDecodingError
        }
        
        guard let newRefresh = extractCookieValue(from: http, cookieName: "refreshToken") else {
            TokenManager.shared.clearAll()
            throw NetworkError.responseDecodingError
        }
        TokenManager.shared.saveRefreshToken(newRefresh)
    }
    
    func reissueSseAccessToken() async throws -> String {
        guard let refresh = TokenManager.shared.getRefreshToken(), !refresh.isEmpty else {
            throw NetworkError.clientError(statusCode: 401)
        }
        
        let urlString = Config.baseURL + EndPoint.sseToken.url
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("refreshToken=\(refresh)", forHTTPHeaderField: "Cookie")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw NetworkError.unknownError }
        
        NetworkLogger.shared.responseLog(http, data: data)
        
        if (400...499).contains(http.statusCode) { throw NetworkError.clientError(statusCode: http.statusCode) }
        if (500...599).contains(http.statusCode) { throw NetworkError.internalServerError }
        guard (200...299).contains(http.statusCode) else { throw NetworkError.unknownError }
        
        do {
            let decoded = try JSONDecoder().decode(BaseResponse<AccessTokenData>.self, from: data)
            guard let tokenData = decoded.data else { throw NetworkError.noData }
            TokenManager.shared.saveSseToken(tokenData.accessToken)
            return tokenData.accessToken
        } catch {
            throw NetworkError.responseDecodingError
        }
    }
    
    private func extractCookieValue(from response: HTTPURLResponse, cookieName: String) -> String? {
        let headers = response.allHeaderFields
        
        if let setCookie = headers["Set-Cookie"] as? String {
            return parseCookie(from: setCookie, cookieName: cookieName)
        }
        
        if let setCookies = headers["Set-Cookie"] as? [String] {
            for item in setCookies {
                if let value = parseCookie(from: item, cookieName: cookieName) {
                    return value
                }
            }
        }
        
        for (k, v) in headers {
            guard let key = (k as? String)?.lowercased(), key == "set-cookie" else { continue }
            
            if let str = v as? String, let value = parseCookie(from: str, cookieName: cookieName) {
                return value
            }
            
            if let arr = v as? [String] {
                for item in arr {
                    if let value = parseCookie(from: item, cookieName: cookieName) {
                        return value
                    }
                }
            }
        }
        
        return nil
    }
    
    private func parseCookie(from setCookie: String, cookieName: String) -> String? {
        // 예: "refreshToken=abc123; Path=/; HttpOnly; Secure"
        let parts = setCookie
            .split(separator: ";")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        for part in parts where part.hasPrefix("\(cookieName)=") {
            return String(part.dropFirst("\(cookieName)=".count))
        }
        
        return nil
    }
}
