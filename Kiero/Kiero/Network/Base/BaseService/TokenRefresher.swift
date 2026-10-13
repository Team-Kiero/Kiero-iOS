//
//  TokenRefresher.swift
//  Kiero
//
//  Created by 신혜연 on 2/24/26.
//

import Foundation

actor TokenRefresher {
    
    static let shared = TokenRefresher()
    private var refreshTask: Task<Void, Error>?
    private var refreshAllTask: Task<Void, Error>?
    private var sseRefreshTask: Task<String, Error>?
    private init() {}
    
    func refreshAccessToken() async throws {
        if let task = refreshTask {
            return try await task.value
        }
        
        let task = Task {
            try await performRefreshAccessToken()
        }
        
        refreshTask = task
        defer { refreshTask = nil }
        
        try await task.value
    }
    
    private func performRefreshAccessToken() async throws {
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
            if [401, 403].contains(http.statusCode) {
                TokenManager.shared.clearAll()
            }
            throw NetworkError.clientError(statusCode: http.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(BaseResponse<AccessTokenData>.self, from: data)
        guard let tokenData = decoded.data else { throw NetworkError.noData }
        
        let newRefresh = extractCookieValue(from: http, cookieName: "refreshToken") ?? refresh
        TokenManager.shared.saveAccessToken(tokenData.accessToken)
        TokenManager.shared.saveRefreshToken(newRefresh)
    }
    
    func refreshAllTokens() async throws {
        if let task = refreshAllTask {
            return try await task.value
        }
        
        let task = Task {
            try await performRefreshAllTokens()
        }
        
        refreshAllTask = task
        defer { refreshAllTask = nil }
        
        try await task.value
    }
    
    private func performRefreshAllTokens() async throws {
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
            if [401, 403].contains(http.statusCode) {
                TokenManager.shared.clearAll()
            }
            throw NetworkError.clientError(statusCode: http.statusCode)
        }
        
        let decoded = try JSONDecoder().decode(BaseResponse<AccessTokenData>.self, from: data)
        guard let tokenData = decoded.data else { throw NetworkError.noData }
        
        guard let newRefresh = extractCookieValue(from: http, cookieName: "refreshToken") else {
            throw NetworkError.responseDecodingError
        }
        
        TokenManager.shared.saveAccessToken(tokenData.accessToken)
        TokenManager.shared.saveRefreshToken(newRefresh)
    }
    
    func reissueSseAccessToken() async throws -> String {
        if let task = sseRefreshTask {
            return try await task.value
        }

        let task = Task {
            try await performReissueSseAccessToken()
        }

        sseRefreshTask = task
        defer { sseRefreshTask = nil }

        return try await task.value
    }

    private func performReissueSseAccessToken() async throws -> String {
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
        guard let url = response.url,
              let setCookie = response.value(forHTTPHeaderField: "Set-Cookie") else { return nil }

        return HTTPCookie.cookies(withResponseHeaderFields: ["Set-Cookie": setCookie], for: url)
            .first { $0.name == cookieName }?.value
    }
}
