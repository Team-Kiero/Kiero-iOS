//
//  NetworkServicing.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

protocol NetworkServicing {
    func request<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable?,
        didRetry: Bool
    ) async throws -> Response
}

extension NetworkServicing {
    func request<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable? = nil,
        didRetry: Bool = false
    ) async throws -> Response {
        try await request(endPoint: endPoint, body: body, didRetry: didRetry)
    }
}
