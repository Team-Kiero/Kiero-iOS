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
    case parentTab
    case childTab
}

final class AuthGateViewModel {

    private let routeSubject = PassthroughSubject<AuthGateRoute, Never>()
    var route: AnyPublisher<AuthGateRoute, Never> { routeSubject.eraseToAnyPublisher() }

    func decideRoute() {

        guard TokenManager.shared.getAccessToken() != nil else {
            routeSubject.send(.pickRole)
            return
        }

        let role = (TokenManager.shared.getUserRole() ?? "").lowercased()

        if role.contains("parent") {
            routeSubject.send(.parentTab)
        } else if role.contains("child") {
            routeSubject.send(.childTab)
        } else {
            routeSubject.send(.pickRole)
        }
    }
}
