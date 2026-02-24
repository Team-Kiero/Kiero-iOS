//
//  RequestBuilder.swift
//  Kiero
//
//  Created by 신혜연 on 2/24/26.
//

import Foundation

struct RequestBuilder {
    
    static func build(
        endPoint: EndPoint,
        body: Encodable?
    ) throws -> URLRequest {
        
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
        
        var request = URLRequest(url: url)
        request.httpMethod = endPoint.method
        request.timeoutInterval = 5.0
        
        endPoint.header.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(AnyEncodable(body))
        }
        
        return request
    }
}
