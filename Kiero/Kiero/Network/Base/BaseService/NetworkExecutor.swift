//
//  NetworkExecutor.swift
//  Kiero
//
//  Created by 신혜연 on 2/24/26.
//

import Foundation

struct NetworkExecutor {
    
    static func execute(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.unknownError
        }
        
        NetworkLogger.shared.responseLog(http, data: data)
        
        return (data, http)
    }
}
