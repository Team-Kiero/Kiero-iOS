//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

import KakaoSDKAuth
import Moya

final class AppDIContainer: ViewControllerFactory {
    static let shared = AppDIContainer()
    private init() {}
}

// MARK: -

extension AppDIContainer {
    
    // MARK: - ServiceFactory
    
    func makeKakaoAuthService() -> KakaoAuthServiceType {
        KakaoAuthService()
    }
    
    // MARK: - RepositoryFactory
    
    func makeAuthRepository() -> AuthRepositoryType {
        AuthRepository(provider: MoyaProvider<AuthAPI>())
    }
}

// MARK: - Start DIContainer

extension AppDIContainer {
    func makePickRoleViewController() -> UIViewController {
        let viewModel = PickRoleViewModel()
        return PickRoleViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - ParentTab DIContainer

extension AppDIContainer {
    func makeParentsOnboardingViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
    }
    
    func makeScheduleViewController() -> UIViewController {
        let viewModel = ScheduleViewModel()
        return ScheduleViewController(viewModel: viewModel, diContainer: self)
    }
    
    func makeNotificationFeedViewController() -> UIViewController {
        // TODO: NotificationFeedViewController()로 치환
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
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
    func makeChildOnboardingViewController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
    }

    func makeDailyJourneyViewController() -> UIViewController {
        // TODO: DailyJourneyViewController()로 치환
        let vc = UIViewController()
        vc.view.backgroundColor = .kBlack
        return vc
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
