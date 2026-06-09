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
    case parentRequiredTerms([RequiredTerm])
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
            decideChildRoute()
            return
        }
        
        routeSubject.send(.pickRole)
    }
    
    private func decideChildRoute() {
        Task {
            do {
                let status: ParentWithdrawalStatusDTO = try await BaseService.shared.request(
                    endPoint: .checkParentWithdrawalStatus
                )
                
                await MainActor.run {
                    if status.isParentWithdrawn {
                        LogoutHelper.logoutToPickRole()
                    } else {
                        self.routeSubject.send(.childTab)
                    }
                }
            } catch {
                await MainActor.run {
                    self.routeSubject.send(.childTab)
                }
            }
        }
    }
    
    private func decideParentRoute() {
        Task {
            do {
                if let requiredTerms = try await checkRequiredTerms() {
                    await MainActor.run {
                        TokenManager.shared.saveRequiredTermsIds(requiredTerms.map { $0.termsId })
                        self.routeSubject.send(.parentRequiredTerms(requiredTerms))
                    }
                    return
                }
                
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
}
