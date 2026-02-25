//
//  AppDIContainer+ViewModels.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

// MARK: - ViewModels

extension AppDIContainer {
    
    // MARK: - Login
    
    func makePickRoleViewModel() -> PickRoleViewModel {
        PickRoleViewModel()
    }
    
    func makeParentLoginViewModel() -> ParentLoginViewModel {
        ParentLoginViewModel(kakaoService: makeKakaoAuthService())
    }
    
    func makeParentOnboardingViewModel() -> ParentOnboardingViewModel {
        ParentOnboardingViewModel()
    }
    
    func makeChildOnboardingViewModel() -> ChildrenOnboardingViewModel {
        ChildrenOnboardingViewModel(
            items: ChildOnboardingScript.items,
            userName: appContext.userName
        )
    }
    
    // MARK: - Onboarding
    
    func makeChildLoadingViewModel() -> BaseViewModel {
        BaseViewModel()
    }
    
    // MARK: - Schedule
    
    func makeScheduleViewModel() -> ScheduleViewModel {
        ScheduleViewModel(
            service: makeScheduleService(),
            context: appContext
        )
    }
    
    func makeAddScheduleViewModel() -> AddScheduleViewModel {
        AddScheduleViewModel(
            service: makeAddScheduleService(),
            context: appContext
        )
    }
    
    // MARK: - Notification
    
    func makeNotificationFeedViewModel() -> NotificationFeedViewModel {
        NotificationFeedViewModel(
            feedService: makeNotificationFeedService(),
            scheduleService: makeScheduleService(),
            tokenRefresher: tokenRefresher,
            sseManager: sseManager,
            context: appContext,
            tokenStore: tokenStore
        )
    }
    
    // MARK: - Mission
    
    func makeMissionViewModel() -> MissionViewModel {
        MissionViewModel(
            service: makeMissionService(),
            context: appContext
        )
    }
    
    func makeWriteMissionViewModel() -> WriteMissionViewModel {
        WriteMissionViewModel(
            service: makeWriteMissionService(),
            context: appContext
        )
    }
    
    func makeLoadingViewModel() -> LoadingViewModel {
        LoadingViewModel()
    }
    
    func makeAIMissionViewModel() -> AIMissionViewModel {
        AIMissionViewModel(service: makeAIMissionService())
    }
    
    // MARK: - DailyJourney
    
    func makeDailyJourneyViewModel() -> DailyJourneyViewModel {
        DailyJourneyViewModel()
    }
    
    // MARK: - CoinMission
    
    func makeCoinMissionViewModel() -> CoinMissionViewModel {
        CoinMissionViewModel()
    }
    
    // MARK: - WishWell
    
    func makeWishWellViewModel() -> WishWellViewModel {
        WishWellViewModel(service: makeWishWellService())
    }
}
