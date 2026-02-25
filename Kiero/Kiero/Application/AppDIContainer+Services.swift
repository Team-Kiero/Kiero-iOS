//
//  AppDIContainer+Services.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

extension AppDIContainer {
    
    // MARK: - Login
    
    func makeKakaoAuthService() -> KakaoAuthServiceType { KakaoAuthService() }
    
    // MARK: - Schedule
    
    func makeScheduleService() -> ScheduleServiceType {
        ScheduleService(network: networkService)
    }
    func makeAddScheduleService() -> AddScheduleServiceType { AddScheduleService() }
    
    // MARK: - Notification
    
    func makeNotificationFeedService() -> FeedServiceType { FeedService() }
    
    // MARK: - Mission
    
    func makeMissionService() -> MissionServiceType { MissionService() }
    func makeWriteMissionService() -> WriteMissionServiceType { WriteMissionService() }
    func makeAIMissionService() -> AIMissionServiceType { AIMissionService() }
    
    // MARK: - WishWell
    
    func makeWishWellService() -> WishWellServiceType { WishWellService() }
}
