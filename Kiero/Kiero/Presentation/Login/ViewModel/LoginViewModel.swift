//
//  LoginViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//


import Foundation
import Combine

final class LoginViewModel {
    
    let kakaoButtonTapped = PassthroughSubject<Void, Never>()
    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    var state: AnyPublisher<LoginState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    let route = PassthroughSubject<LoginRoute, Never>()
    private let kakaoService: KakaoAuthService
    private let repo: AuthRepositoryType
    private var cancellables = Set<AnyCancellable>()

    init(
        kakaoService: KakaoAuthService = KakaoAuthService(),
        repo: AuthRepositoryType
    ) {
        self.kakaoService = kakaoService
        self.repo = repo
        bind()
    }

    private func bind() {
        kakaoButtonTapped
            .sink { [weak self] in
                self?.requestKakaoLogin()
            }
            .store(in: &cancellables)
    }

    private func requestKakaoLogin() {
        stateSubject.send(.loading)

        kakaoService.loginWithKakao()
            .mapError { _ in NetworkError.unknownError }
            .flatMap { [repo] kakaoAccessToken in
                repo.loginWithKakao(accessToken: kakaoAccessToken)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self else { return }
                if case .failure(let error) = completion {
                    self.stateSubject.send(.failure(error.errorDescription))
                }
            } receiveValue: { [weak self] loginData in

                TokenManager.shared.saveAccessToken(loginData.accessToken)

                self?.stateSubject.send(.idle)
                self?.route.send(.home)
            }
            .store(in: &cancellables)
    }
}
