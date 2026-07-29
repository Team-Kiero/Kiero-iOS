//
//  ParentOnboardingViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import Combine
import Foundation

enum ParentOnboardingRoute {
    case invite(childLastName: String, childFirstName: String, inviteCode: String, issuedAt: Date)
    case logout
}

final class ParentOnboardingViewModel: BaseViewModel {

    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<ParentOnboardingRoute, Never>()
    
    private let name = TokenManager.shared.getUserName()
    private let profileURL = TokenManager.shared.getProfile()
    private let sseManager = AppDIContainer.shared.sseManager

    let lastName = CurrentValueSubject<String, Never>("")
    let firstName = CurrentValueSubject<String, Never>("")

    var state: AnyPublisher<LoginState, Never> { stateSubject.eraseToAnyPublisher() }
    var route: AnyPublisher<ParentOnboardingRoute, Never> { routeSubject.eraseToAnyPublisher() }

    var isGenerateEnabled: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(lastName, firstName)
            .map { last, first in
                let l = last.trimmingCharacters(in: .whitespacesAndNewlines)
                let f = first.trimmingCharacters(in: .whitespacesAndNewlines)
                return !l.isEmpty && !f.isEmpty
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func generateInviteCode(childLastName: String, childFirstName: String) {
        let last = childLastName.trimmingCharacters(in: .whitespacesAndNewlines)
        let first = childFirstName.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !last.isEmpty, !first.isEmpty else {
            stateSubject.send(.failure("성/이름을 입력해주세요"))
            return
        }

        stateSubject.send(.loading)

        Task { [weak self] in
            guard let self else { return }
            do {
                let req = InviteCodeRequest(childLastName: last, childFirstName: first)
                let data: InviteCodeData = try await BaseService.shared.request(
                    endPoint: .postInviteCode,
                    body: req
                )

                AmplitudeManager.shared.track(.inviteCodeCreated, properties: [
                    AnalyticsEventProperty.inviteCodeHash: AnalyticsIdentity.hashed(data.code),
                    AnalyticsEventProperty.source: "onboarding"
                ])

                print("✅ [VM] 2) reissueSseAccessToken() 호출 직전")

                let sseToken = try await TokenRefresher.shared.reissueSseAccessToken()

                print("✅ [VM] 2) sseToken 발급 성공:", sseToken.prefix(10))

                await MainActor.run {
                    print("✅ [VM] 3) startIfNeeded 호출 직전")
                    self.sseManager.startIfNeeded(initialToken: sseToken) { payload in
                        print("✅ [VM] SSE payload 수신:", payload.eventType)
                        NotificationCenter.default.post(name: .didReceiveSseEvent, object: payload)
                    }
                    print("✅ [VM] 3) startIfNeeded 호출 완료")
                }

                // 4) 라우팅
                await MainActor.run {
                    self.stateSubject.send(.idle)
                    self.routeSubject.send(.invite(
                        childLastName: data.childLastName,
                        childFirstName: data.childFirstName,
                        inviteCode: data.code,
                        issuedAt: Date()
                    ))
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
    
    func logout() {
        routeSubject.send(.logout)
    }
}
