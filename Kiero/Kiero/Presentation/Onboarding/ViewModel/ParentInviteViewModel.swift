//
//  ParentInviteViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import Foundation

enum ParentInviteRoute {
    case parentTab
    case toast(String)
}

final class ParentInviteViewModel: BaseViewModel {

    let childLastName: String
    let childFirstName: String
    var childName: String { "\(childLastName)\(childFirstName)" }

    private let expiresIn: TimeInterval
    private var expiresAt: Date

    private let inviteCodeSubject: CurrentValueSubject<String, Never>
    var inviteCode: AnyPublisher<String, Never> { inviteCodeSubject.eraseToAnyPublisher() }
    var inviteCodeValue: String { inviteCodeSubject.value }

    private let remainingTextSubject: CurrentValueSubject<String, Never>
    var remainingText: AnyPublisher<String, Never> { remainingTextSubject.eraseToAnyPublisher() }

    private let isExpiredSubject = CurrentValueSubject<Bool, Never>(false)
    var isExpired: AnyPublisher<Bool, Never> { isExpiredSubject.eraseToAnyPublisher() }
    var isExpiredValue: Bool { isExpiredSubject.value }

    private let expiredEventSubject = PassthroughSubject<Void, Never>()
    var expiredEvent: AnyPublisher<Void, Never> { expiredEventSubject.eraseToAnyPublisher() }

    private var timerCancellable: AnyCancellable?

    private let isReissuingSubject = CurrentValueSubject<Bool, Never>(false)
    var isReissuing: AnyPublisher<Bool, Never> { isReissuingSubject.eraseToAnyPublisher() }
    
    private let routeSubject = PassthroughSubject<ParentInviteRoute, Never>()
    var route: AnyPublisher<ParentInviteRoute, Never> { routeSubject.eraseToAnyPublisher() }
    
    private let isStartingSubject = CurrentValueSubject<Bool, Never>(false)
    var isStarting: AnyPublisher<Bool, Never> { isStartingSubject.eraseToAnyPublisher() }

    init(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date,
        expiresIn: TimeInterval = 10 * 60
    ) {
        self.childLastName = childLastName
        self.childFirstName = childFirstName

        self.expiresIn = expiresIn
        self.expiresAt = issuedAt.addingTimeInterval(expiresIn)

        self.inviteCodeSubject = CurrentValueSubject(inviteCode)
        self.remainingTextSubject = CurrentValueSubject(Self.format(seconds: Int(expiresIn)))

        super.init()
        startCountdown()
    }

    func reissueInviteCode() {
        guard isExpiredValue else { return }
        guard isReissuingSubject.value == false else { return }

        isReissuingSubject.send(true)

        Task { [weak self] in
            guard let self else { return }
            do {
                let req = InviteCodeRequest(childLastName: childLastName, childFirstName: childFirstName)

                let data: InviteCodeData = try await BaseService.shared.request(
                    endPoint: .postInviteCode,
                    body: req
                )

                AmplitudeManager.shared.track(.inviteCodeCreated, properties: [
                    AnalyticsEventProperty.inviteCodeHash: AnalyticsIdentity.hashed(data.code),
                    AnalyticsEventProperty.source: "reissue"
                ])

                await MainActor.run {
                    self.inviteCodeSubject.send(data.code)
                    self.expiresAt = Date().addingTimeInterval(self.expiresIn)
                    self.restartCountdown()
                    self.isReissuingSubject.send(false)
                }
            } catch {
                await MainActor.run {
                    self.isReissuingSubject.send(false)
                }
            }
        }
    }

    private func restartCountdown() {
        timerCancellable?.cancel()
        timerCancellable = nil

        isExpiredSubject.send(false)
        remainingTextSubject.send(Self.format(seconds: Int(expiresIn)))

        startCountdown()
    }

    private func startCountdown() {
        updateRemainingTime()

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateRemainingTime()
            }
    }

    private func updateRemainingTime() {
        let remaining = Int(expiresAt.timeIntervalSinceNow.rounded(.down))

        if remaining <= 0 {
            remainingTextSubject.send("00:00")

            if isExpiredSubject.value == false {
                isExpiredSubject.send(true)
                expiredEventSubject.send(())
            } else {
                isExpiredSubject.send(true)
            }

            timerCancellable?.cancel()
            timerCancellable = nil
            return
        }

        remainingTextSubject.send(Self.format(seconds: remaining))
        isExpiredSubject.send(false)
    }

    private static func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    func start() {
        guard isStartingSubject.value == false else { return }
        
        isStartingSubject.send(true)
        
        Task { [weak self] in
            guard let self else { return }
            do {
                let termsIds = TokenManager.shared.getRequiredTermsIds()
                if termsIds.isEmpty == false {
                    let request = AgreeRequiredTermsRequestDTO(
                        termsIds: termsIds
                    )
                    let _: EmptyResponse = try await BaseService.shared.request(
                        endPoint: .agreeRequiredTerms,
                        body: request
                    )
                    TokenManager.shared.removeRequiredTermsIds()
                    AmplitudeManager.shared.track(.termsAgreementCompleted)
                }
                AmplitudeManager.shared.track(.onboardingCompleted)
                await MainActor.run {
                    self.isStartingSubject.send(false)
                    self.routeSubject.send(.parentTab)
                }
            } catch {
                await MainActor.run {
                    self.isStartingSubject.send(false)
                    self.routeSubject.send(.toast("약관 동의 처리에 실패했습니다."))
                }
            }
        }
    }
    
    deinit {
        timerCancellable?.cancel()
    }
}
