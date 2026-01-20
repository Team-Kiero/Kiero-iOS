//
//  ParentOnboardingViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import Combine
import Foundation

enum ParentOnboardingRoute {
    case invite(childFullName: String, inviteCode: String, issuedAt: Date)
}

final class ParentOnboardingViewModel: BaseViewModel {
    let name: String
    let profileURL: String

    private let stateSubject = CurrentValueSubject<LoginState, Never>(.idle)
    private let routeSubject = PassthroughSubject<ParentOnboardingRoute, Never>()

    var state: AnyPublisher<LoginState, Never> { stateSubject.eraseToAnyPublisher() }
    var route: AnyPublisher<ParentOnboardingRoute, Never> { routeSubject.eraseToAnyPublisher() }

    init(name: String, profileURL: String) {
        self.name = name
        self.profileURL = profileURL
        super.init()
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

                let fullName = "\(data.childLastName)\(data.childFirstName)"

                await MainActor.run {
                    self.stateSubject.send(.idle)
                    self.routeSubject.send(.invite(
                        childFullName: fullName,
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
}
