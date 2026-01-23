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
    
    private let routeSubject = PassthroughSubject<AuthGateRoute, Never>()
    var route: AnyPublisher<AuthGateRoute, Never> { routeSubject.eraseToAnyPublisher() }
    
    func decideRoute() {
        
        guard TokenManager.shared.getAccessToken() != nil else {
            routeSubject.send(.pickRole)
            return
        }
        
        
        let role = (TokenManager.shared.getUserRole() ?? "").lowercased()
        
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
        Task {
            do {
                let children: [ChildrenData] = try await BaseService.shared.request(
                    endPoint: .fetchChildren
                )
                
                await MainActor.run {
                    if children.isEmpty {
                        self.routeSubject.send(.parentOnboarding)
                    } else {
                        self.routeSubject.send(.parentTab)
                    }
                }
            } catch {
                await MainActor.run {
                    self.routeSubject.send(.parentOnboarding)
                }
            }
        }
    }
}
