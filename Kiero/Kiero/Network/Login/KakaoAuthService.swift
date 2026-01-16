//
//  KakaoAuthService.swift
//  Kiero
//
//  Created by 안치욱 on 1/9/26.
//


import Combine
import KakaoSDKUser

final class KakaoAuthService: KakaoAuthServiceType {
    func loginWithKakao() -> AnyPublisher<String, Error> {
        Future { promise in
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { token, error in
                    if let error = error { promise(.failure(error)) }
                    else { promise(.success(token?.accessToken ?? "")) }
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { token, error in
                    if let error = error { promise(.failure(error)) }
                    else { promise(.success(token?.accessToken ?? "")) }
                }
            }
        }.eraseToAnyPublisher()
    }
}
