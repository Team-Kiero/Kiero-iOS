//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

import KakaoSDKAuth
import Moya

final class AppDIContainer: ViewControllerFactory, ServiceFactory{
    
    static let shared = AppDIContainer()
    private init() {}
    
    lazy var sseManager: SseStreamManager = {
        SseStreamManager(sseURL: Config.sseURL)
    }()
}

// MARK: - Login

extension AppDIContainer {
    func makeKakaoAuthService() -> KakaoAuthServiceType {
        return KakaoAuthService()
    }
    
    func makeParentLoginViewController() -> UIViewController {
        let vm = ParentLoginViewModel(kakaoService: makeKakaoAuthService())
        return ParentLoginViewController(viewModel: vm, diContainer: self)
    }
    
    func makePickRoleViewController() -> UIViewController {
        let viewModel = PickRoleViewModel()
        return PickRoleViewController(viewModel: viewModel, diContainer: self)
    }
    
    //    func makeParentOnboardingViewController() -> UIViewController {
    //        let vm = ParentOnboardingViewModel(name: <#String#>, profileURL: <#String#>)
    //        return ParentOnboardingViewController(viewModel: vm, diContainer: self)
    //    }
    
    func makeChildOnboardingViewController() -> UIViewController {
        let userName = TokenManager.shared.getFirstName() ?? "사용자"
        let items = ChildOnboardingScript.items
        let viewModel = ChildrenOnboardingViewModel(
            items: items,
            userName: userName
        )
        return ChildrenOnboardingViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Onboarding

extension AppDIContainer {
    func makeChildLoadingViewController() -> UIViewController {
        let viewModel = BaseViewModel()
        return ChildrenLoadingViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Schedule

extension AppDIContainer {
    func makeScheduleService() -> ScheduleServiceType {
        return ScheduleService()
    }
    
    func makeScheduleViewController() -> UIViewController {
        let service = makeScheduleService()
        let selectedChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
        
        let viewModel = ScheduleViewModel(service: service, childId: selectedChildId)
        return ScheduleViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeScheduleChildViewController(viewModel: ScheduleViewModel) -> ScheduleChildViewController {
        return ScheduleChildViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeAddScheduleViewController() -> UIViewController {
        let service = AddScheduleService()
        let selectedChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
        
        let viewModel = AddScheduleViewModel(service: service, childId: selectedChildId)
        return AddScheduleViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Notification

extension AppDIContainer {
    func makeNotificationFeedService() -> FeedServiceType {
        FeedService()
    }
    
    func makeNotificationFeedViewModel() -> NotificationFeedViewModel {
        return NotificationFeedViewModel(
            feedService: makeNotificationFeedService(),
            scheduleService: makeScheduleService()
        )
    }
    
    func makeNotificationFeedViewController() -> UIViewController {
        let viewModel = makeNotificationFeedViewModel()
        return NotificationFeedViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Mission

extension AppDIContainer {
    func makeMissionService() -> MissionServiceType {
        return MissionService()
    }
    
    func makeAIMissionService() -> AIMissionServiceType {
        return AIMissionService()
    }
    
    func makeMissionViewController() -> UIViewController {
        let service = makeMissionService()
        let viewModel = MissionViewModel(service: service)
        return MissionViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeWriteMissionViewController() -> UIViewController {
        let service = WriteMissionService()
        let selectedChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
        
        let viewModel = WriteMissionViewModel(service: service, childId: selectedChildId)
        return WriteMissionViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeLoadingViewController() -> UIViewController {
        let viewModel = LoadingViewModel()
        return LoadingViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeAIMissionViewController() -> UIViewController {
        let service = makeAIMissionService()
        let viewModel = AIMissionViewModel(service: service)
        return AIMissionViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - DailyJourney

extension AppDIContainer {
    func makeDailyJourneyViewController() -> UIViewController {
        let viewModel = DailyJourneyViewModel()
        return DailyJourneyViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - CoinMission

extension AppDIContainer {
    func makeCoinMissionViewController() -> UIViewController {
        let viewModel = CoinMissionViewModel()
        return CoinMissionViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - WishWell

extension AppDIContainer {
    func makeWishWellService() -> WishWellServiceType {
        return WishWellService()
    }
    
    func makeWishWellViewModel() -> WishWellViewModel {
        return WishWellViewModel(service: makeWishWellService())
    }
    
    func makeWishWellViewController() -> UIViewController {
        let viewModel = makeWishWellViewModel()
        return WishWellViewController(viewModel: viewModel, diContainer: self)
    }
}
