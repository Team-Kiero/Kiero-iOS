//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

final class AppDIContainer {
    
    static let shared = AppDIContainer()
    
    let userSessionStorage: UserSessionStorageType
    let authTokenStorage: AuthTokenStorageType
    
    lazy var feedService: FeedServiceType = {
        FeedService()
    }()
    
    lazy var sseTokenRefresher: SseTokenRefresherType = {
        SseTokenRefresher()
    }()
    
    lazy var sseManager: SseStreamManager = {
        SseStreamManager.shared
    }()
    
    private init(
        userSessionStorage: UserSessionStorageType = UserSessionStorage(),
        authTokenStorage: AuthTokenStorageType = AuthTokenStorage()
    ) {
        self.userSessionStorage = userSessionStorage
        self.authTokenStorage = authTokenStorage
    }
}

// MARK: - Feature DIContainer Factory

extension AppDIContainer {
    func makeAuthDIContainer() -> AuthDIContainer {
        AuthDIContainer(appDIContainer: self)
    }

    func makeScheduleDIContainer() -> ScheduleDIContainer {
        ScheduleDIContainer(appDIContainer: self)
    }

    func makeMissionDIContainer() -> MissionDIContainer {
        MissionDIContainer(appDIContainer: self)
    }

    func makeNotificationDIContainer() -> NotificationDIContainer {
        NotificationDIContainer(appDIContainer: self)
    }

    func makeMainFeatureDIContainer() -> MainFeatureDIContainer {
        MainFeatureDIContainer(appDIContainer: self)
    }
}

extension AppDIContainer: ViewControllerFactory {
    
    func makeTabBarViewController(isParent: Bool) -> TabBarViewController {
        TabBarViewController(
            factory: self,
            isParent: isParent,
            feedService: feedService,
            sseTokenRefresher: sseTokenRefresher,
            sseManager: sseManager
        )
    }
    
    func makeMissionCompleteViewController(
        image: UIImage,
        stoneType: StoneType?,
        scheduleDetailId: Int?
    ) -> MissionCompleteViewController {
        makeMainFeatureDIContainer()
            .makeMissionCompleteViewController(
                image: image,
                stoneType: stoneType,
                scheduleDetailId: scheduleDetailId
            )
    }
    
    func makeParentInviteViewController(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date
    ) -> ParentInviteViewController {
        makeAuthDIContainer().makeParentInviteViewController(
            childLastName: childLastName,
            childFirstName: childFirstName,
            inviteCode: inviteCode,
            issuedAt: issuedAt
        )
    }
    
    func makeDailyJourneyMapViewController() -> DailyJourneyMapViewController {
        makeMainFeatureDIContainer()
            .makeDailyJourneyMapViewController()
    }
    
    func makeGiveFireStoneViewController(
        count: Int
    ) -> GiveFireStoneViewController {
        makeMainFeatureDIContainer()
            .makeGiveFireStoneViewController(count: count)
    }
    
    func makeParentLoginViewController() -> ParentLoginViewController {
        makeAuthDIContainer().makeParentLoginViewController()
    }
    
    func makeChildrenLoginViewController() -> ChildrenLoginViewController {
        makeAuthDIContainer().makeChildrenLoginViewController()
    }
    
    func makeParentOnboardingViewController() -> ParentOnboardingViewController {
        makeAuthDIContainer().makeParentOnboardingViewController()
    }
    
    func makeAuthGateViewController() -> AuthGateViewController {
        makeAuthDIContainer().makeAuthGateViewController()
    }

    func makeTodayStatusViewController() -> TodayStatusHostingController {
        makeMainFeatureDIContainer().makeTodayStatusViewController()
    }

    func makeScheduleViewController() -> ScheduleViewController {
        makeScheduleDIContainer().makeScheduleViewController()
    }

    func makeRewardViewController() -> RewardHostingController {
        makeMainFeatureDIContainer().makeRewardViewController()
    }

    func makeMyPageViewController() -> MyPageHostingController {
        makeMainFeatureDIContainer().makeMyPageViewController()
    }

    func makeNotificationFeedViewController() -> NotificationFeedViewController {
        makeNotificationDIContainer().makeNotificationFeedViewController()
    }
    
    func makeEditScheduleViewController(
        schedule: Schedule
    ) -> AddScheduleViewController {
        makeScheduleDIContainer()
            .makeEditScheduleViewController(schedule: schedule)
    }
    
    func makeAddScheduleViewController() -> AddScheduleViewController {
        makeScheduleDIContainer().makeAddScheduleViewController(
            isFireLit: false,
            scheduleList: []
        )
    }

    func makeAddScheduleViewController(
        isFireLit: Bool,
        scheduleList: [Schedule]
    ) -> AddScheduleViewController {
        makeScheduleDIContainer().makeAddScheduleViewController(
            isFireLit: isFireLit,
            scheduleList: scheduleList
        )
    }

    func makeMissionViewController() -> MissionViewController {
        makeMissionDIContainer().makeMissionViewController()
    }

    func makeWriteMissionViewController() -> WriteMissionViewController {
        makeMissionDIContainer().makeWriteMissionViewController()
    }

    func makeLoadingViewController() -> LoadingViewController {
        makeMissionDIContainer().makeLoadingViewController()
    }

    func makeAIMissionViewController() -> AIMissionViewController {
        makeMissionDIContainer().makeAIMissionViewController()
    }

    func makeChildOnboardingViewController() -> ChildrenOnboardingViewController {
        makeAuthDIContainer().makeChildOnboardingViewController()
    }

    func makeDailyJourneyViewController() -> DailyJourneyViewController {
        makeMainFeatureDIContainer().makeDailyJourneyViewController()
    }

    func makeCoinMissionViewController() -> CoinMissionViewController {
        makeMainFeatureDIContainer().makeCoinMissionViewController()
    }

    func makeWishWellViewController() -> WishWellViewController {
        makeMainFeatureDIContainer().makeWishWellViewController()
    }
    
    func makeChildLoadingViewController() -> ChildrenLoadingViewController {
        makeAuthDIContainer().makeChildLoadingViewController()
    }
    
    func makeTimeTableViewController(viewModel: ScheduleViewModel) -> TimeTableViewController {
        makeScheduleDIContainer().makeTimeTableViewController(viewModel: viewModel)
    }
}
