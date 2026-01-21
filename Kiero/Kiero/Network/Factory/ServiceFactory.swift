//
//  AuthFactory.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import Combine
import UIKit

protocol ServiceFactory {
    func makeKakaoAuthService() -> KakaoAuthServiceType
    func makeScheduleService() -> ScheduleServiceType
    func makeWishWellService() -> WishWellServiceType
}

protocol KakaoAuthServiceType {
    func loginWithKakao() async throws -> String
}
