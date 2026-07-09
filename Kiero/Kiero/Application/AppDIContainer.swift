//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import SwiftUI
import UIKit

import KakaoSDKAuth
import Moya

final class AppDIContainer: ViewControllerFactory, ServiceFactory{
    
    static let shared = AppDIContainer()
    private init() {}
    
    lazy var sseManager: SseStreamManager = {
        SseStreamManager.shared
    }()
}

// MARK: - Login

extension AppDIContainer {
    func makeKakaoAuthService() -> KakaoAuthServiceType {
        return KakaoAuthService()
    }
    
    func makePickRoleViewController() -> UIViewController {
        let viewModel = PickRoleViewModel()
        return PickRoleViewController(viewModel: viewModel)
    }
    
    func makeParentLoginViewController() -> UIViewController {
        let vm = ParentLoginViewModel(kakaoService: makeKakaoAuthService())
        return ParentLoginViewController(viewModel: vm)
    }
    
    func makeParentOnboardingViewController() -> UIViewController {
        let vm = ParentOnboardingViewModel()
        return ParentOnboardingViewController(viewModel: vm)
    }
    
    func makeParentInviteViewController(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date
    ) -> UIViewController {
        let vm = ParentInviteViewModel(
            childLastName: childLastName,
            childFirstName: childFirstName,
            inviteCode: inviteCode,
            issuedAt: issuedAt
        )
        return ParentInviteViewController(viewModel: vm)
    }
    
    func makeChildLoginViewController() -> UIViewController {
        let vm = ChildLoginViewModel()
        return ChildLoginViewController(viewModel: vm)
    }
    
    func makeChildOnboardingViewController() -> UIViewController {
        let userName = TokenManager.shared.getFirstName() ?? "사용자"
        let items = ChildOnboardingScript.items
        let viewModel = ChildOnboardingViewModel(
            items: items,
            userName: userName
        )
        let vc = ChildOnboardingViewController(viewModel: viewModel)
        vc.makeLoadingVC = { self.makeChildLoadingViewController() }
        
        return vc
    }
    
    func makeChildLoadingViewController() -> UIViewController {
        let viewModel = BaseViewModel()
        return ChildLoadingViewController(viewModel: viewModel)
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
        
        let vc = ScheduleViewController(viewModel: viewModel)
        
        vc.makeTimeTableVC = { vm in
            self.makeTimeTableViewController(viewModel: vm)
        }
        vc.makeAddScheduleVC = { isFireLit, scheduleList in
            self.makeAddScheduleViewController(isFireLit: isFireLit, scheduleList: scheduleList)
        }
        vc.makeNotificationFeedVC = {
            self.makeNotificationFeedViewController()
        }
        
        return vc
    }
    
    func makeTimeTableViewController(viewModel: ScheduleViewModel) -> TimeTableViewController {
        let vc = TimeTableViewController(viewModel: viewModel)
        vc.makeEditScheduleVC = { schedule in
            self.makeEditScheduleViewController(schedule: schedule)
        }
        return vc
    }
    
    func makeAddScheduleViewController() -> UIViewController {
        return makeAddScheduleViewController(isFireLit: false, scheduleList: [])
    }
    
    func makeAddScheduleViewController(isFireLit: Bool, scheduleList: [Schedule]) -> AddScheduleViewController {
        let service = AddScheduleService()
        let selectedChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
        
        let viewModel = AddScheduleViewModel(service: service, childId: selectedChildId)
        viewModel.isFireLit = isFireLit
        viewModel.scheduleList = scheduleList
        
        return AddScheduleViewController(viewModel: viewModel)
    }
    
    func makeEditScheduleViewController(schedule: Schedule) -> AddScheduleViewController {
        let vc = makeAddScheduleViewController(isFireLit: false, scheduleList: [])
        vc.isEditMode = true
        vc.editingSchedule = schedule
        return vc
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
        return NotificationFeedViewController(viewModel: viewModel)
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
        let vc = MissionViewController(viewModel: viewModel)
        
        vc.makeWriteMissionVC = { self.makeWriteMissionViewController() as! WriteMissionViewController }
        vc.makeEditMissionVC = { self.makeWriteMissionViewController() as! WriteMissionViewController }
        vc.makeAIMissionVC = { self.makeAIMissionViewController() }
        vc.makeNotificationFeedVC = { self.makeNotificationFeedViewController() }
        
        return vc
    }
    
    func makeWriteMissionViewController() -> UIViewController {
        let service = WriteMissionService()
        let selectedChildId = UserDefaults.standard.integer(forKey: "selectedChildId")
        let viewModel = WriteMissionViewModel(service: service, childId: selectedChildId)
        return WriteMissionViewController(viewModel: viewModel)
    }

    func makeLoadingViewController() -> UIViewController {
        let viewModel = LoadingViewModel()
        return LoadingViewController(viewModel: viewModel)
    }

    func makeAIMissionViewController() -> UIViewController {
        let service = makeAIMissionService()
        let viewModel = AIMissionViewModel(service: service)
        let vc = AIMissionViewController(viewModel: viewModel)
        vc.makeLoadingVC = { self.makeLoadingViewController() as! LoadingViewController }
        return vc
    }
}

// MARK: - DailyJourney

extension AppDIContainer {
    func makeDailyJourneyViewController() -> UIViewController {
        let viewModel = DailyJourneyViewModel()
        let vc = DailyJourneyViewController(viewModel: viewModel)
        
        vc.makeDailyJourneyMapVC = {
            let vm = DailyJourneyMapViewModel()
            return DailyJourneyMapViewController(viewModel: vm)
        }
        vc.makeGiveFireStoneVC = { stoneCount in
            let vm = GiveFireStoneViewModel(count: stoneCount)
            return GiveFireStoneViewController(viewModel: vm)
        }
        
        return vc
    }
}

// MARK: - CoinMission

extension AppDIContainer {
    func makeCoinMissionViewController() -> UIViewController {
        let viewModel = CoinMissionViewModel()
        return CoinMissionViewController(viewModel: viewModel)
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
        let vc = WishWellViewController(viewModel: viewModel)
        vc.makeWishRoomVC = { self.makeWishRoomViewController() }
        return vc
    }
}

// MARK: - WishRoom

extension AppDIContainer {
    func makeWishRoomViewController() -> UIViewController {
        let viewModel = WishRoomViewModel()
        let vc = WishRoomHostingController(viewModel: viewModel)
        vc.makeWishWellVC = { self.makeWishWellViewController() }
        return vc
    }
}

// MARK: - MySpace

extension AppDIContainer {
    func makeMySpaceViewController() -> UIViewController {
        let vc = MySpaceHostingController()
        vc.makeWishRoomVC = { self.makeWishRoomViewController() }
        return vc
    }
}

// MARK: - TodayStatus

extension AppDIContainer {
    func makeTodayStatusViewController() -> UIViewController {
        let viewModel = TodayStatusViewModel()
        return TodayStatusHostingController(viewModel: viewModel)
    }
}

// MARK: - Reward

extension AppDIContainer {
    func makeRewardViewController() -> UIViewController {
        let viewModel = RewardViewModel()
        return RewardHostingController(viewModel: viewModel)
    }
}

// MARK: - MyPage

extension AppDIContainer {
    func makeMyPageViewController() -> UIViewController {
        let viewModel = MyPageViewModel()
        return MyPageHostingController(viewModel: viewModel)
    }
}
