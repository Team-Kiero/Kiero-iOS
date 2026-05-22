//
//  AuthDIContainer.swift
//  Kiero
//
//  Created by 안치욱 on 5/1/26.
//

import UIKit

final class AuthDIContainer {
    
    private let appDIContainer: AppDIContainer
    
    private lazy var kakaoAuthService: KakaoAuthServiceType = {
        KakaoAuthService()
    }()
    
    private lazy var authService: AuthServiceType = {
        AuthService(
            kakaoAuthService: kakaoAuthService
        )
    }()
    
    private lazy var userSessionStorage: UserSessionStorageType = {
        appDIContainer.userSessionStorage
    }()
    
    private lazy var authTokenStorage: AuthTokenStorageType = {
        appDIContainer.authTokenStorage
    }()
    
    private lazy var parentInviteService: ParentInviteServiceType = {
        ParentInviteService()
    }()
    
    private lazy var scheduleService: ScheduleServiceType = {
        ScheduleService()
    }()
    
    private lazy var sseTokenRefresher: SseTokenRefresherType = {
        appDIContainer.sseTokenRefresher
    }()
    
    init(appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
    }
}

extension AuthDIContainer {
    
    func makeAuthGateViewModel() -> AuthGateViewModel {
        AuthGateViewModel(
            authTokenStorage: authTokenStorage,
            scheduleService: scheduleService
        )
    }
}

extension AuthDIContainer {
    
    func makeAuthGateViewController() -> AuthGateViewController {
        let viewModel = makeAuthGateViewModel()
        return AuthGateViewController(viewModel: viewModel)
    }
    
    func makeParentLoginViewController() -> ParentLoginViewController {
        let viewModel = ParentLoginViewModel(
            authService: authService,
            authTokenStorage: authTokenStorage
        )

        return ParentLoginViewController(viewModel: viewModel)
    }
    
    func makeParentInviteViewController(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date
    ) -> ParentInviteViewController {
        let viewModel = ParentInviteViewModel(
            childLastName: childLastName,
            childFirstName: childFirstName,
            inviteCode: inviteCode,
            issuedAt: issuedAt,
            inviteService: parentInviteService,
            authTokenStorage: authTokenStorage,
            userSessionStorage: appDIContainer.userSessionStorage
        )

        return ParentInviteViewController(viewModel: viewModel)
    }
    
    func makeChildrenLoginViewController() -> ChildrenLoginViewController {
        let viewModel = ChildrenLoginViewModel(
            authService: authService,
            authTokenStorage: authTokenStorage
        )

        return ChildrenLoginViewController(viewModel: viewModel)
    }
    
    func makeParentOnboardingViewController() -> ParentOnboardingViewController {
        let viewModel = ParentOnboardingViewModel(
            parentInviteService: parentInviteService,
            authTokenStorage: authTokenStorage,
            sseManager: appDIContainer.sseManager,
            sseTokenRefresher: sseTokenRefresher
        )
        
        return ParentOnboardingViewController(viewModel: viewModel)
    }
    
    func makeChildOnboardingViewController() -> ChildrenOnboardingViewController {
        let viewModel = ChildrenOnboardingViewModel(
            items: ChildOnboardingScript.items,
            userName: userSessionStorage.firstName ?? "사용자"
        )
        
        return ChildrenOnboardingViewController(viewModel: viewModel)
    }
    
    func makeChildLoadingViewController() -> ChildrenLoadingViewController {
        let viewModel = BaseViewModel()
        return ChildrenLoadingViewController(viewModel: viewModel)
    }
}
