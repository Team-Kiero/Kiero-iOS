//
//  ChildLoginViewModel.swift
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

final class ChildLoginViewModel: BaseViewModel {
    
    // MARK: - Publisher
    
    private let stateSubject = CurrentValueSubject<ChildLoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<ChildLoginRoute, Never>()
    
    var state: AnyPublisher<ChildLoginState, Never> {
        stateSubject.eraseToAnyPublisher()
    }
    
    var route: AnyPublisher<ChildLoginRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Public Action
    
    func signup(lastName: String, firstName: String, inviteCode: String) {
        let last = lastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = inviteCode.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !last.isEmpty, !first.isEmpty, !code.isEmpty else { return }
        
        stateSubject.send(.loading)
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let body = ChildSignupRequest(
                    lastName: last,
                    firstName: first,
                    inviteCode: code
                )
                
                let data: ChildSignupData = try await BaseService.shared.request(
                    endPoint: .childSignup(
                        lastName: last,
                        firstName: first,
                        inviteCode: code
                    ),
                    body: body
                )
                
                TokenManager.shared.saveAccessToken(data.accessToken)
                TokenManager.shared.saveRefreshToken(data.refreshToken)
                TokenManager.shared.saveUserRole(data.role)
                TokenManager.shared.saveUserName("\(data.lastName)\(data.firstName)")
                TokenManager.shared.saveFirstName(data.firstName)
                
                AmplitudeManager.shared.refreshUserId()
                AmplitudeManager.shared.setUserProperties([
                    .loginMethod: AnalyticsLoginMethod.inviteCode.rawValue,
                    .childConnected: true
                ])
                AmplitudeManager.shared.track(.loginCompleted, properties: [
                    AnalyticsEventProperty.loginMethod: AnalyticsLoginMethod.inviteCode.rawValue
                ])
                AmplitudeManager.shared.track(.childConnectionCompleted, properties: [
                    AnalyticsEventProperty.inviteCodeHash: AnalyticsIdentity.hashed(code)
                ])
                
                await FCMTokenManager.shared.sendCurrentTokenToServer()
                
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
                    self.stateSubject.send(.failure("이름이나 초대코드를 다시 확인해줘!"))
                }
            }
        }
    }
}
