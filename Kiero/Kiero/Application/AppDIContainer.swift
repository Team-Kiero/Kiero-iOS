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

extension AppDIContainer {
    func makeAddScheduleViewController() -> UIViewController {
        let viewModel = AddScheduleViewModel()
        return AddScheduleViewController(viewModel: viewModel, diContainer: self)
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
    
    func makeWishWellViewController() -> UIViewController {
        let viewModel = WishWellViewModel()
        return WishWellViewController(viewModel: viewModel, diContainer: self)
    }
}
