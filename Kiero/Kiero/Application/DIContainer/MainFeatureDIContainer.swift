//
//  MainFeatureDIContainer.swift
//  Kiero
//
//  Created by 안치욱 on 5/1/26.
//

import UIKit

final class MainFeatureDIContainer {

    private let appDIContainer: AppDIContainer
    
    private lazy var authTokenStorage: AuthTokenStorageType = {
        AuthTokenStorage()
    }()
    
    private lazy var logoutService: LogoutServiceType = {
        LogoutService()
    }()
    
    private lazy var scheduleService: ScheduleServiceType = {
        ScheduleService()
    }()
    
    private lazy var dailyJourneyService: DailyJourneyServiceType = {
        DailyJourneyService()
    }()
    
    private lazy var dailyJourneyMapService: DailyJourneyMapServiceType = {
        DailyJourneyMapService()
    }()
    
    private lazy var wishWellService: WishWellServiceType = {
        WishWellService()
    }()
    
    private lazy var missionService: MissionServiceType = {
        MissionService()
    }()
    
    private lazy var coinMissionService: CoinMissionServiceType = {
        CoinMissionService()
    }()
    
    private lazy var rewardService: RewardServiceType = {
        RewardService()
    }()
    
    private lazy var todayStatusService: TodayStatusServiceType = {
        TodayStatusService()
    }()

    private lazy var sseTokenRefresher: SseTokenRefresherType = {
        SseTokenRefresher()
    }()
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

// MARK: - ViewModel

extension MainFeatureDIContainer {
    
    func makeGiveFireStoneViewModel(count: Int) -> GiveFireStoneViewModel {
        GiveFireStoneViewModel(count: count, dailyJourneyService: dailyJourneyService)
    }
}

extension MainFeatureDIContainer {
    
    func makeDailyJourneyViewController() -> DailyJourneyViewController {
        let viewModel = DailyJourneyViewModel(
            dailyJourneyService: dailyJourneyService,
            wishWellService: wishWellService
        )
        
        return DailyJourneyViewController(viewModel: viewModel)
    }
    
    func makeDailyJourneyMapViewController() -> DailyJourneyMapViewController {
        let viewModel = DailyJourneyMapViewModel(
            dailyJourneyMapService: dailyJourneyMapService,
            dailyJourneyService: dailyJourneyService
        )
        
        let viewController = DailyJourneyMapViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
    
    func makeRewardViewController() -> RewardHostingController {
        let viewModel = RewardViewModel(
            rewardService: rewardService,
            userSessionStorage: appDIContainer.userSessionStorage
        )
        
        return RewardHostingController(viewModel: viewModel)
    }
    
    func makeGiveFireStoneViewController(
        count: Int
    ) -> GiveFireStoneViewController {
        let viewModel = GiveFireStoneViewModel(
            count: count,
            dailyJourneyService: dailyJourneyService
        )
        
        let viewController = GiveFireStoneViewController(viewModel: viewModel)
        
        viewController.hidesBottomBarWhenPushed = true
        return viewController
    }
    
    func makeCoinMissionViewController() -> CoinMissionViewController {
        let viewModel = CoinMissionViewModel(
            wishWellService: wishWellService,
            missionService: missionService,
            coinMissionService: coinMissionService
        )
        
        return CoinMissionViewController(viewModel: viewModel)
    }
    
    func makeMissionCompleteViewController(
        image: UIImage,
        stoneType: StoneType?,
        scheduleDetailId: Int?
    ) -> MissionCompleteViewController {
        let viewModel = MissionCompleteViewModel(
            dailyJourneyService: dailyJourneyService
        )
        
        viewModel.capturedImage = image
        viewModel.receivedStoneType = stoneType
        viewModel.scheduleDetailId = scheduleDetailId
        
        let viewController = MissionCompleteViewController(viewModel: viewModel)
        
        viewController.initialImage = image
        
        return viewController
    }
    
    func makeWishWellViewController() -> WishWellViewController {
        let viewModel = WishWellViewModel(
            service: wishWellService,
            sseTokenRefresher: sseTokenRefresher,
            sseManager: appDIContainer.sseManager
        )
        
        return WishWellViewController(viewModel: viewModel)
    }
    
    func makeTodayStatusViewController() -> TodayStatusHostingController {
        let viewModel = TodayStatusViewModel(
            todayStatusService: todayStatusService,
            userSessionStorage: appDIContainer.userSessionStorage,
            sseTokenRefresher: sseTokenRefresher,
            sseManager: appDIContainer.sseManager
        )
        
        return TodayStatusHostingController(viewModel: viewModel)
    }
    
    func makeMyPageViewController() -> MyPageHostingController {
        let viewModel = MyPageViewModel(
            logoutService: logoutService,
            scheduleService: scheduleService,
            authTokenStorage: authTokenStorage
        )
        
        return MyPageHostingController(viewModel: viewModel)
    }
}
