//
//  AuthRepository.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//

import Combine

import Moya
import CombineMoya

protocol AuthRepositoryType {
    func loginWithKakao(accessToken: String) -> AnyPublisher<LoginData, NetworkError>
    func reissueAccessToken() -> AnyPublisher<String, NetworkError>
    func reissueAllTokens() -> AnyPublisher<String, NetworkError>
}

final class AuthRepository: AuthRepositoryType {

    private let provider: MoyaProvider<AuthAPI>

    init(provider: MoyaProvider<AuthAPI>) {
        self.provider = provider
    }

    func loginWithKakao(accessToken: String) -> AnyPublisher<LoginData, NetworkError> {
        provider.requestPublisher(.kakaoAccessToken(token: accessToken))
            .filterSuccessfulStatusCodes()
            .map(BaseResponse<LoginData>.self)
            .tryMap { base in
                guard base.status == 200 else { throw NetworkError.clientError(statusCode: base.status) }
                guard let data = base.data else { throw NetworkError.noData }
                return data
            }
            .mapError { _ in .unknownError }
            .eraseToAnyPublisher()
    }

    func reissueAccessToken() -> AnyPublisher<String, NetworkError> {
        provider.requestPublisher(.reissueAccessToken)
            .filterSuccessfulStatusCodes()
            .map(BaseResponse<AccessTokenData>.self)
            .tryMap { base in
                guard base.status == 200 else { throw NetworkError.clientError(statusCode: base.status) }
                guard let data = base.data else { throw NetworkError.noData }
                return data.accessToken
            }
            .mapError { _ in .unknownError }
            .eraseToAnyPublisher()
    }

    func reissueAllTokens() -> AnyPublisher<String, NetworkError> {
        provider.requestPublisher(.reissueAllTokens)
            .filterSuccessfulStatusCodes()
            .map(BaseResponse<AccessTokenData>.self)
            .tryMap { base in
                guard base.status == 200 else { throw NetworkError.clientError(statusCode: base.status) }
                guard let data = base.data else { throw NetworkError.noData }
                return data.accessToken
            }
            .mapError { _ in .unknownError }
            .eraseToAnyPublisher()
    }
}
