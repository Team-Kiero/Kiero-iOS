//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

import KakaoSDKAuth
import Moya

final class AppDIContainer: ViewControllerFactory, ServiceFactory, RepositoryFactory {
    static let shared = AppDIContainer()
    private init() {}
}

// MARK: - Login

extension AppDIContainer {
    func makeKakaoAuthService() -> KakaoAuthServiceType {
        return KakaoAuthService()
    }
    
    func makeAuthRepository() -> AuthRepositoryType {
        return AuthRepository(provider: MoyaProvider<AuthAPI>())
    }
    
    func makeParentLoginViewController() -> UIViewController {
        let vm = ParentLoginViewModel(kakaoService: makeKakaoAuthService(), repo: makeAuthRepository())
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
        let items: [SpeechItem] = [
            .init(image: .imgStory1, name: "꾸비", lines: ["드디어 만났다! 나의 짝꿍 근영", "난 꼬마 히어로 꾸비야. 우리 같이 모험을 떠나볼까?"], highlightKeywords: []),
            .init(image: .imgStory2, name: "꾸비", lines: ["다른 도깨비들은 장난치는 걸 좋아하지만,", "난 '영웅의 불씨'를 품고 태어난 특별한 도깨비야!", "너의 노력을 멋진 소원으로 바꾸는 꼬마 히어로 지"], highlightKeywords: ["꼬마 히어로"]),
            .init(image: .imgStory3, name: "꾸비", lines: ["그런데 큰일이야...", "배에 있는 ‘영웅의 불씨'가 자꾸 꺼지려고 해.", "나 혼자서는 지킬 수 없거든", "오직 너만이 이 불씨를 다시 키울 수 있어!"], highlightKeywords: ["오직 너만이 이 불씨를 다시 키울 수 있어!"]),
            .init(image: .imgStory4, name: "꾸비", lines: ["오늘의 여정을 따라 하루를 보내고", "불조각을 나에게 건네줘!", "너가 준 [용기, 인내, 지혜의 불조각] 이", "내 마음의 불꽃을 키워줄거야."], highlightKeywords: ["[용기, 인내, 지혜의 불조각]"]),
            .init(image: .imgStory5, name: "꾸비", lines: ["그 힘으로 내가 반짝이는 금화를 만들어줄게!", "소원의 우물에서 금화를 통해", "너의 소원을 이룰 수 있을거야!"], highlightKeywords: [])
        ]
        let viewModel = ChildrenOnboardingViewModel(items: items)
        return ChildrenOnboardingViewController(viewModel: viewModel, diContainer: self)
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
        let viewModel = AddScheduleViewModel()
        return AddScheduleViewController(viewModel: viewModel, diContainer: self)
    }
}

// MARK: - Notification

extension AppDIContainer {
    func makeNotificationFeedViewController() -> UIViewController {
        let viewModel = NotificationFeedViewModel()
        return NotificationFeedViewController(viewModel: viewModel, diContainer: self)
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
    func makeWishWellViewController() -> UIViewController {
        let viewModel = WishWellViewModel()
        return WishWellViewController(viewModel: viewModel, diContainer: self)
    }
}
