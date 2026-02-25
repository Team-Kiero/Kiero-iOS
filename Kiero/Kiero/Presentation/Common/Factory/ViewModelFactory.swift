//
//  ViewModelFactory.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

protocol ViewModelFactory {
    // Login
    func makePickRoleViewModel() -> PickRoleViewModel
    func makeParentLoginViewModel() -> ParentLoginViewModel
    func makeParentOnboardingViewModel() -> ParentOnboardingViewModel
    func makeChildOnboardingViewModel() -> ChildrenOnboardingViewModel

    // Schedule
    func makeScheduleViewModel() -> ScheduleViewModel
    func makeAddScheduleViewModel() -> AddScheduleViewModel

    // Notification
    func makeNotificationFeedViewModel() -> NotificationFeedViewModel

    // Mission
    func makeMissionViewModel() -> MissionViewModel
    func makeWriteMissionViewModel() -> WriteMissionViewModel
    func makeLoadingViewModel() -> LoadingViewModel
    func makeAIMissionViewModel() -> AIMissionViewModel

    // Child tab
    func makeDailyJourneyViewModel() -> DailyJourneyViewModel
    func makeCoinMissionViewModel() -> CoinMissionViewModel

    // WishWell
    func makeWishWellViewModel() -> WishWellViewModel
}
