//
//  ParentLoginViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//

import Combine
import Foundation

final class ParentLoginViewModel: BaseViewModel, ViewModelType {
    
    struct Input {
        let kakaoButtonTapped: AnyPublisher<Void, Never>
        let appleButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let state: AnyPublisher<LoginState, Never>
        let route: AnyPublisher<LoginRoute, Never>
    }
    
    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<LoginRoute, Never>()
    
    private let kakaoService: any KakaoAuthServiceType
    private let appleService: any AppleAuthServiceType
    private var isLoggingIn = false
    
    init(
        kakaoService: any KakaoAuthServiceType = KakaoAuthService(),
        appleService: any AppleAuthServiceType = AppleAuthService()
    ) {
        self.kakaoService = kakaoService
        self.appleService = appleService
        super.init()
    }
    
    func transform(input: Input) -> Output {
        input.kakaoButtonTapped
            .sink { [weak self] in
                self?.requestKakaoLogin()
            }
            .store(in: &cancellables)
        
        input.appleButtonTapped
            .sink { [weak self] in
                self?.requestAppleLogin()
            }
            .store(in: &cancellables)
        
        return Output(
            state: stateSubject.eraseToAnyPublisher(),
            route: routeSubject.eraseToAnyPublisher()
        )
    }
    
    private func requestKakaoLogin() {
        guard !isLoggingIn else { return }
        isLoggingIn = true
        stateSubject.send(.loading)
        Task { [weak self] in
            guard let self else { return }
            defer { self.isLoggingIn = false }
            do {
                let kakaoToken = try await kakaoService.loginWithKakao()
                let loginData: LoginData = try await BaseService.shared.request(
                    endPoint: .kakaoAccessToken(token: kakaoToken)
                )
                TokenManager.shared.saveAccessToken(loginData.accessToken)
                TokenManager.shared.saveRefreshToken(loginData.refreshToken)
                if let image = loginData.image {
                    TokenManager.shared.saveProfile(image)
                }
                TokenManager.shared.saveUserName(loginData.name)
                TokenManager.shared.saveUserRole(loginData.role)
                
                if try await routeRequiredTermsIfNeeded() {
                    return
                }
                
                let children: ChildListResponse = try await BaseService.shared.request(
                    endPoint: .fetchChildren
                )
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
    
    private func requestAppleLogin() {
        guard !isLoggingIn else { return }
        isLoggingIn = true
        stateSubject.send(.loading)
        Task { [weak self] in
            guard let self else { return }
            defer { self.isLoggingIn = false }
            do {
                let credential = try await appleService.loginWithApple()
                let loginData: LoginData = try await BaseService.shared.request(
                    endPoint: .appleLogin(
                        identityToken: credential.identityToken,
                        authorizationCode: credential.authorizationCode,
                        name: credential.name
                    ),
                    body: AppleLoginRequestDTO(
                        identityToken: credential.identityToken,
                        authorizationCode: credential.authorizationCode,
                        name: credential.name
                    )
                )
                TokenManager.shared.saveAccessToken(loginData.accessToken)
                TokenManager.shared.saveRefreshToken(loginData.refreshToken)
                if let image = loginData.image {
                    TokenManager.shared.saveProfile(image)
                }
                TokenManager.shared.saveUserName(loginData.name)
                TokenManager.shared.saveUserRole(loginData.role)
                
                if try await routeRequiredTermsIfNeeded() {
                    return
                }
                
                let children: ChildListResponse = try await BaseService.shared.request(
                    endPoint: .fetchChildren
                )
                await MainActor.run {
                    self.stateSubject.send(.idle)
                    if children.isEmpty {
                        self.routeSubject.send(.parentOnboarding)
                    } else {
                        self.routeSubject.send(.parentTab)
                    }
                }
            } catch let error as AppleLoginError {
                await MainActor.run {
                    self.stateSubject.send(.idle)
                    switch error {
                    case .cancelled:
                        break
                    default:
                        self.routeSubject.send(.toast("애플 로그인에 실패했어요."))
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
    
    private func checkRequiredTerms() async throws -> [RequiredTerm]? {
        let agreement: RequiredTermsAgreementStatusData = try await BaseService.shared.request(
            endPoint: .requiredTermsAgreementStatus
        )

        guard agreement.isRequiredTermsAllAgreed == false else {
            return nil
        }

        let terms: [RequiredTerm] = try await BaseService.shared.request(
            endPoint: .requiredTerms
        )

        return terms
    }
    
    private func routeRequiredTermsIfNeeded() async throws -> Bool {
        if let requiredTerms = try await checkRequiredTerms() {
            await MainActor.run {
                self.stateSubject.send(.idle)
                self.routeSubject.send(.requiredTerms(requiredTerms))
            }
            return true
        }

        return false
    }
}
