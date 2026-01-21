//
//  ParentInviteViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import Foundation

final class ParentInviteViewModel: BaseViewModel {

    let parentName: String
    let profileURL: String

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

    init(
        parentName: String,
        profileURL: String,
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date,
        expiresIn: TimeInterval = 10 * 60
    ) {
        self.parentName = parentName
        self.profileURL = profileURL
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
        tick()

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
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

    deinit {
        timerCancellable?.cancel()
    }
}
