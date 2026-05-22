//
//  AuthGateViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import Foundation

enum AuthGateRoute {
    case pickRole
    case parentOnboarding
    case parentTab
    case childTab
}

final class AuthGateViewModel {

    private let authTokenStorage: AuthTokenStorageType
    private let scheduleService: ScheduleServiceType

    private let routeSubject = PassthroughSubject<AuthGateRoute, Never>()
    var route: AnyPublisher<AuthGateRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }

    private var cancellables = Set<AnyCancellable>()

    init(
        authTokenStorage: AuthTokenStorageType,
        scheduleService: ScheduleServiceType
    ) {
        self.authTokenStorage = authTokenStorage
        self.scheduleService = scheduleService
    }

    func decideRoute() {
        guard authTokenStorage.accessToken != nil else {
            routeSubject.send(.pickRole)
            return
        }

        let role = (authTokenStorage.userRole ?? "").lowercased()

        if role.contains("parent") {
            decideParentRoute()
            return
        }

        if role.contains("child") {
            routeSubject.send(.childTab)
            return
        }

        routeSubject.send(.pickRole)
    }

    private func decideParentRoute() {
        scheduleService.fetchChildren()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.routeSubject.send(.parentOnboarding)
                }
            } receiveValue: { [weak self] children in
                if children.isEmpty {
                    self?.routeSubject.send(.parentOnboarding)
                } else {
                    self?.routeSubject.send(.parentTab)
                }
            }
            .store(in: &cancellables)
    }
}
