//
//  ParentLoginViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//

import Foundation
import Combine

final class ParentLoginViewModel: BaseViewModel, ViewModelType {

    // MARK: - Input / Output

    struct Input {
        let kakaoButtonTapped: AnyPublisher<Void, Never>
    }

    struct Output {
        let state: AnyPublisher<LoginState, Never>
        let route: AnyPublisher<LoginRoute, Never>
    }

    // MARK: - Private

    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<LoginRoute, Never>()

    private let kakaoService: any KakaoAuthServiceType
    private let repo: AuthRepositoryType

    // MARK: - Init

    init(
        kakaoService: any KakaoAuthServiceType = KakaoAuthService(),
        repo: AuthRepositoryType
    ) {
        self.kakaoService = kakaoService
        self.repo = repo
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

    // MARK: - Business Logic

    private func requestKakaoLogin() {
        stateSubject.send(.loading)

        kakaoService.loginWithKakao()
            .mapError { _ in NetworkError.unknownError }
            .flatMap { [repo] token in
                repo.loginWithKakao(accessToken: token)
                    .mapError { _ in NetworkError.unknownError }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.stateSubject.send(.failure(error.errorDescription))
                }
            } receiveValue: { [weak self] loginData in
                TokenManager.shared.saveAccessToken(loginData.accessToken)
                self?.stateSubject.send(.idle)
                self?.routeSubject.send(.parentOnboarding(name: loginData.name, url: loginData.image))
            }
            .store(in: &cancellables)
    }
}
