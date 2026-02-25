//
//  AppDIContainer+ViewControllers.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

import UIKit

// MARK: - ViewControllers

extension AppDIContainer {
    
    // MARK: - Login
    
    func makePickRoleViewController() -> UIViewController {
        PickRoleViewController(
            viewModel: makePickRoleViewModel(),
            diContainer: self
        )
    }
    
    func makeParentLoginViewController() -> UIViewController {
        ParentLoginViewController(
            viewModel: makeParentLoginViewModel(),
            diContainer: self
        )
    }
    
    func makeParentOnboardingViewController() -> UIViewController {
        ParentOnboardingViewController(
            viewModel: makeParentOnboardingViewModel(),
            diContainer: self
        )
    }
    
    func makeChildOnboardingViewController() -> UIViewController {
        ChildrenOnboardingViewController(
            viewModel: makeChildOnboardingViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - Onboarding
    
    func makeChildLoadingViewController() -> UIViewController {
        ChildrenLoadingViewController(
            viewModel: makeChildLoadingViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - Schedule
    
    func makeScheduleViewController() -> UIViewController {
        ScheduleViewController(
            viewModel: makeScheduleViewModel(),
            diContainer: self
        )
    }
    
    func makeScheduleChildViewController(viewModel: ScheduleViewModel) -> ScheduleChildViewController {
        ScheduleChildViewController(
            viewModel: viewModel,
            diContainer: self
        )
    }
    
    func makeAddScheduleViewController() -> UIViewController {
        AddScheduleViewController(
            viewModel: makeAddScheduleViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - Notification
    
    func makeNotificationFeedViewController() -> UIViewController {
        NotificationFeedViewController(
            viewModel: makeNotificationFeedViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - Mission
    
    func makeMissionViewController() -> UIViewController {
        MissionViewController(
            viewModel: makeMissionViewModel(),
            diContainer: self
        )
    }
    
    func makeWriteMissionViewController() -> UIViewController {
        WriteMissionViewController(
            viewModel: makeWriteMissionViewModel(),
            diContainer: self
        )
    }
    
    func makeLoadingViewController() -> UIViewController {
        LoadingViewController(
            viewModel: makeLoadingViewModel(),
            diContainer: self
        )
    }
    
    func makeAIMissionViewController() -> UIViewController {
        AIMissionViewController(
            viewModel: makeAIMissionViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - DailyJourney
    
    func makeDailyJourneyViewController() -> UIViewController {
        DailyJourneyViewController(
            viewModel: makeDailyJourneyViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - CoinMission
    
    func makeCoinMissionViewController() -> UIViewController {
        CoinMissionViewController(
            viewModel: makeCoinMissionViewModel(),
            diContainer: self
        )
    }
    
    // MARK: - WishWell
    
    func makeWishWellViewController() -> UIViewController {
        WishWellViewController(
            viewModel: makeWishWellViewModel(),
            diContainer: self
        )
    }
}

