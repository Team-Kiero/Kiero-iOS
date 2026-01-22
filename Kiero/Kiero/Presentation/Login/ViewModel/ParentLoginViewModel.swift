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
    }

    struct Output {
        let state: AnyPublisher<LoginState, Never>
        let route: AnyPublisher<LoginRoute, Never>
    }

    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<LoginRoute, Never>()

    private let kakaoService: any KakaoAuthServiceType

    init(kakaoService: any KakaoAuthServiceType = KakaoAuthService()) {
        self.kakaoService = kakaoService
        super.init()
    }

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

    private func requestKakaoLogin() {
        stateSubject.send(.loading)

        Task { [weak self] in
            guard let self else { return }

            do {
                let kakaoToken = try await kakaoService.loginWithKakao()

                let loginData: LoginData = try await BaseService.shared.request(
                    endPoint: .kakaoAccessToken(token: kakaoToken)
                )

                TokenManager.shared.saveAccessToken(loginData.accessToken)
                TokenManager.shared.saveRefreshToken(loginData.refreshToken)
                TokenManager.shared.saveProfile(loginData.image)
                TokenManager.shared.saveUserName(loginData.name)
                TokenManager.shared.saveUserRole(loginData.role)
                TokenManager.shared.saveUserName(loginData.name)
                TokenManager.shared.saveProfile(loginData.image)

                await MainActor.run {
                    self.stateSubject.send(.idle)
                    self.routeSubject.send(.parentOnboarding(name: loginData.name, url: loginData.image))
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
