//
//  AuthInterceptor.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//

import Foundation

import Alamofire
import Combine

final class AuthInterceptor: RequestInterceptor, @unchecked Sendable {

    private let refresher: TokenRefresher
    private var cancellables = Set<AnyCancellable>()

    init(refresher: TokenRefresher) {
        self.refresher = refresher
    }

    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        let path = urlRequest.url?.path ?? ""
        if path.contains("/login")
            || path.contains("/signup")
            || path.contains("/tokens/reissue") {
            completion(.success(urlRequest))
            return
        }
        if let access = TokenManager.shared.getAccessToken() {
            urlRequest.setValue("Bearer \(access)", forHTTPHeaderField: "Authorization")
        }
        completion(.success(urlRequest))
    }

    func retry(_ request: Request,
               for session: Session,
               dueTo error: Error,
               completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              response.statusCode == 401 else {
            completion(.doNotRetryWithError(error))
            return
        }
        refresher.refreshAccessToken()
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    completion(.retry)
                case .failure:
                    TokenManager.shared.clear()
                    completion(.doNotRetryWithError(error))
                }
            }, receiveValue: { })
            .store(in: &cancellables)
    }
}
