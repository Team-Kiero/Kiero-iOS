//
//  ChildrenLoginViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import Foundation

enum ChildLoginRoute {
    case childOnboarding
}

enum ChildLoginState: Equatable {
    case idle
    case loading
    case failure(String)
}

final class ChildrenLoginViewModel: BaseViewModel {

    // MARK: - Dependencies

    private let authService: AuthServiceType
    private let authTokenStorage: AuthTokenStorageType

    // MARK: - Publisher

    private let stateSubject = CurrentValueSubject<ChildLoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<ChildLoginRoute, Never>()

    var state: AnyPublisher<ChildLoginState, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    var route: AnyPublisher<ChildLoginRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }

    // MARK: - Init

    init(
        authService: AuthServiceType,
        authTokenStorage: AuthTokenStorageType
    ) {
        self.authService = authService
        self.authTokenStorage = authTokenStorage
        super.init()
    }

    // MARK: - Public Action

    func signup(
        lastName: String,
        firstName: String,
        inviteCode: String
    ) {
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !last.isEmpty,
              !first.isEmpty,
              !code.isEmpty else { return }

        stateSubject.send(.loading)

        Task { [weak self] in
            guard let self else { return }

            do {
                let data = try await authService.childSignup(
                    lastName: last,
                    firstName: first,
                    inviteCode: code
                )

                authTokenStorage.saveAccessToken(data.accessToken)
                authTokenStorage.saveRefreshToken(data.refreshToken)
                authTokenStorage.saveUserRole(data.role)
                authTokenStorage.saveUserName("\(data.lastName)\(data.firstName)")
                authTokenStorage.saveFirstName(data.firstName)

                await MainActor.run {
                    self.stateSubject.send(.idle)
                    self.routeSubject.send(.childOnboarding)
                }

            } catch let error as NetworkError {
                await MainActor.run {
                    self.stateSubject.send(.failure(error.toastMessage))
                }

            } catch {
                await MainActor.run {
                    self.stateSubject.send(
                        .failure("이름이나 초대코드를 다시 확인해줘!")
                    )
                }
            }
        }
    }
}
