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
        // TODO: ScheduleViewController()로 치환
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
    }
    
    func makeNotificationFeedViewController() -> UIViewController {
        // TODO: NotificationFeedViewController()로 치환
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
    }
}

// MARK: - ChildTab DIContainer

extension AppDIContainer {
    func makeDailyJourneyViewController() -> UIViewController {
        let viewModel = DailyJourneyViewModel()
        let vc = DailyJourneyViewController(viewModel: viewModel, diContainer: self)
        vc.view.backgroundColor = .kBlack
        return vc
    }
    
    func makeCoinMissionViewController() -> UIViewController {
        // TODO: CoinMissionViewController()로 치환
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
    }
    
    func makeWishWellViewController() -> UIViewController {
        // TODO: WishWellViewController()로 치환
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
    }
}
