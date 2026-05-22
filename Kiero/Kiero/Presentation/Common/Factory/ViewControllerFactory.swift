//
//  ViewControllerFactory.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

protocol ViewControllerFactory {
    
    func makeAuthGateViewController() -> AuthGateViewController
    func makeTabBarViewController(isParent: Bool) -> TabBarViewController
    
    // 부모 탭

    func makeParentOnboardingViewController() -> ParentOnboardingViewController
    func makeParentInviteViewController(childLastName: String, childFirstName: String, inviteCode: String, issuedAt: Date) -> ParentInviteViewController
    func makeParentLoginViewController() -> ParentLoginViewController
    func makeTodayStatusViewController() -> TodayStatusHostingController
    func makeScheduleViewController() -> ScheduleViewController
    func makeRewardViewController() -> RewardHostingController
    func makeMyPageViewController() -> MyPageHostingController
    func makeNotificationFeedViewController() -> NotificationFeedViewController
    func makeEditScheduleViewController(schedule: Schedule) -> AddScheduleViewController
    
    func makeAddScheduleViewController() -> AddScheduleViewController
    func makeAddScheduleViewController(isFireLit: Bool, scheduleList: [Schedule]) -> AddScheduleViewController
    func makeMissionViewController() -> MissionViewController
    func makeWriteMissionViewController() -> WriteMissionViewController
    func makeLoadingViewController() -> LoadingViewController
    func makeAIMissionViewController() -> AIMissionViewController
    
    func makeTimeTableViewController(viewModel: ScheduleViewModel) -> TimeTableViewController
    
    // 아이 탭
    
    func makeDailyJourneyViewController() -> DailyJourneyViewController
    func makeDailyJourneyMapViewController() -> DailyJourneyMapViewController
    func makeGiveFireStoneViewController(count: Int) -> GiveFireStoneViewController
    func makeChildrenLoginViewController() -> ChildrenLoginViewController
    func makeChildOnboardingViewController() -> ChildrenOnboardingViewController
    func makeChildLoadingViewController() -> ChildrenLoadingViewController
    func makeCoinMissionViewController() -> CoinMissionViewController
    func makeWishWellViewController() -> WishWellViewController
    func makeMissionCompleteViewController(image: UIImage, stoneType: StoneType?, scheduleDetailId: Int?) -> MissionCompleteViewController
    func makeMySpaceViewController() -> UIViewController
}
