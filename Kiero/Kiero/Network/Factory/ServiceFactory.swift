//
//  AuthFactory.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import Foundation

protocol ServiceFactory {
    // Auth
    func makeKakaoAuthService() -> KakaoAuthServiceType

    // Schedule
    func makeScheduleService() -> ScheduleServiceType
    func makeAddScheduleService() -> AddScheduleServiceType

    // Notification
    func makeNotificationFeedService() -> FeedServiceType

    // Mission
    func makeMissionService() -> MissionServiceType
    func makeWriteMissionService() -> WriteMissionServiceType
    func makeAIMissionService() -> AIMissionServiceType

    // WishWell
    func makeWishWellService() -> WishWellServiceType
}

protocol KakaoAuthServiceType {
    func loginWithKakao() async throws -> String
}
