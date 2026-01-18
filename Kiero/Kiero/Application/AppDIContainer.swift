//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

final class AppDIContainer: ViewControllerFactory {
    static let shared = AppDIContainer()
    private init() {}
}

// MARK: - ParentTab DIContainer

extension AppDIContainer {
    func makeScheduleViewController() -> UIViewController {
        let viewModel = ScheduleViewModel()
        return ScheduleViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeNotificationFeedViewController() -> UIViewController {
        let viewModel = NotificationFeedViewModel()
        return NotificationFeedViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Schedule

extension AppDIContainer {
    func makeAddScheduleViewController() -> UIViewController {
        let viewModel = AddScheduleViewModel()
        return AddScheduleViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeScheduleChildViewController() -> ScheduleChildViewController {
        let viewModel = ScheduleViewModel()
        return ScheduleChildViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Mission

extension AppDIContainer {
    func makeMissionViewController() -> UIViewController {
        let viewModel = MissionViewModel()
        return MissionViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeWriteMissionViewController() -> UIViewController {
        let viewModel = WriteMissionViewModel()
        return WriteMissionViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeLoadingViewController() -> UIViewController {
        let viewModel = LoadingViewModel()
        return LoadingViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeAIMissionViewController() -> UIViewController {
        let viewModel = AIMissionViewModel()
        return AIMissionViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - ChildTab DIContainer

extension AppDIContainer {
    func makeDailyJourneyViewController() -> UIViewController {
        let viewModel = DailyJourneyViewModel()
        return DailyJourneyViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeCoinMissionViewController() -> UIViewController {
        let viewModel = CoinMissionViewModel()
        return CoinMissionViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - WishWell

extension AppDIContainer {
    func makeWishWellViewController() -> UIViewController {
        let viewModel = WishWellViewModel()
        return WishWellViewController(viewModel: viewModel, diContainer: self)
    }
}
