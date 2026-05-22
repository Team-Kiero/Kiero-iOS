//
//  ParentLoginViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//

import Combine
import Foundation

final class ParentLoginViewModel: BaseViewModel, ViewModelType {
    
    // MARK: - Input & Output
    
    struct Input {
        let kakaoButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let state: AnyPublisher<LoginState, Never>
        let route: AnyPublisher<LoginRoute, Never>
    }
    
    // MARK: - Dependencies
    
    private let authService: AuthServiceType
    private let authTokenStorage: AuthTokenStorageType
    
    // MARK: - Properties
    
    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<LoginRoute, Never>()
    
    private var isLoggingIn = false
    
    // MARK: - Init
    
    init(
        authService: AuthServiceType,
        authTokenStorage: AuthTokenStorageType
    ) {
        self.authService = authService
        self.authTokenStorage = authTokenStorage
        super.init()
    }
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        input.kakaoButtonTapped
            .sink { [weak self] in
                self?.requestKakaoLogin()
            }
            .store(in: &cancellables)
        
        return Output(
            state: stateSubject.eraseToAnyPublisher(),
            route: routeSubject.eraseToAnyPublisher()
        )
    }
    
    // MARK: - Login
    
    private func requestKakaoLogin() {
        guard !isLoggingIn else { return }
        isLoggingIn = true
        
        stateSubject.send(.loading)
        
        Task { [weak self] in
            guard let self else { return }
            
            defer { self.isLoggingIn = false }
            
            do {
                let loginData = try await authService.parentLogin()
                authTokenStorage.saveAccessToken(loginData.accessToken)
                authTokenStorage.saveRefreshToken(loginData.refreshToken)
                authTokenStorage.saveProfile(loginData.image)
                authTokenStorage.saveUserName(loginData.name)
                authTokenStorage.saveUserRole(loginData.role)
                let children = try await authService.fetchChildren()
                await MainActor.run {
                    self.stateSubject.send(.idle)
                    if children.isEmpty {
                        self.routeSubject.send(.parentOnboarding)
                    } else {
                        self.routeSubject.send(.parentTab)
                    }
                }
            } catch let error as KakaoLoginError {
                await MainActor.run {
                    self.stateSubject.send(.idle)
                    switch error {
                    case .cancelled:
                        self.routeSubject.send(.toast("로그인이 취소되었습니다."))
                    case .unknown:
                        self.routeSubject.send(.toast("로그인이 취소되었습니다."))
                    }
                }
                
            } catch let error as NetworkError {
                await MainActor.run {
                    self.stateSubject.send(.failure(error.errorDescription))
                }
            } catch {
                await MainActor.run {
                    self.stateSubject.send(.failure("알 수 없는 에러"))
                }
            }
        }
    }
}
