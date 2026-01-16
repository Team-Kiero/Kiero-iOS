//
//  AuthFactory.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import UIKit

import Combine

protocol ServiceFactory {
    func makeKakaoAuthService() -> KakaoAuthServiceType
}

protocol KakaoAuthServiceType {
    func loginWithKakao() -> AnyPublisher<String, Error>
}
