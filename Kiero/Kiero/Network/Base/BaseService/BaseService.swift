//
//  BaseService.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void
    init(_ value: Encodable) { self.encodeFunc = value.encode }
    func encode(to encoder: Encoder) throws { try encodeFunc(encoder) }
}

final class BaseService: NetworkServicing {

    private let tokenRefresher: TokenRefreshing

    init(tokenRefresher: TokenRefreshing) {
        self.tokenRefresher = tokenRefresher
    }

    func request<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable?,
        didRetry: Bool
    ) async throws -> Response {

        do {
            return try await perform(endPoint: endPoint, body: body)

        } catch let error as NetworkError {

            guard case .clientError(let statusCode) = error,
                  statusCode == 401,
                  didRetry == false else {
                throw error
            }

            switch endPoint.refreshPolicy {
            case .none:
                throw error

            case .child:
                try await tokenRefresher.refreshAllTokens()

            case .parent:
                do { try await tokenRefresher.refreshAccessToken() }
                catch { try await tokenRefresher.refreshAllTokens() }
            }

            return try await request(endPoint: endPoint, body: body, didRetry: true)
        }
    }

    private func perform<Response: Decodable>(
        endPoint: EndPoint,
        body: Encodable?
    ) async throws -> Response {

        let request = try RequestBuilder.build(endPoint: endPoint, body: body)
        let (data, httpResponse) = try await NetworkExecutor.execute(request)
        return try ResponseDecoder.decode(data: data, statusCode: httpResponse.statusCode)
    }
}
