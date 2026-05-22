//
//  ParentInviteViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import Foundation

final class ParentInviteViewModel: BaseViewModel {

    let childLastName: String
    let childFirstName: String
    var childName: String { "\(childLastName)\(childFirstName)" }

    private let inviteService: ParentInviteServiceType
    private let authTokenStorage: AuthTokenStorageType
    private var userSessionStorage: UserSessionStorageType

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

    private let childJoinedSubject = PassthroughSubject<Void, Never>()
    var childJoined: AnyPublisher<Void, Never> { childJoinedSubject.eraseToAnyPublisher() }

    private let isReissuingSubject = CurrentValueSubject<Bool, Never>(false)
    var isReissuing: AnyPublisher<Bool, Never> { isReissuingSubject.eraseToAnyPublisher() }

    private var timerCancellable: AnyCancellable?
    private var isChecking = false

    var userName: String {
        authTokenStorage.userName ?? ""
    }

    var profileURL: String {
        authTokenStorage.profile ?? ""
    }

    init(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date,
        inviteService: ParentInviteServiceType,
        authTokenStorage: AuthTokenStorageType,
        userSessionStorage: UserSessionStorageType,
        expiresIn: TimeInterval = 10 * 60
    ) {
        self.childLastName = childLastName
        self.childFirstName = childFirstName
        self.inviteService = inviteService
        self.authTokenStorage = authTokenStorage
        self.userSessionStorage = userSessionStorage

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
                let data = try await inviteService.reissueInviteCode(
                    childLastName: childLastName,
                    childFirstName: childFirstName
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

    func checkConnectionOnce() {
        guard !isChecking else { return }
        guard isExpiredValue == false else { return }

        isChecking = true

        Task { [weak self] in
            guard let self else { return }

            defer { self.isChecking = false }

            do {
                let data = try await inviteService.checkConnection(
                    childLastName: childLastName,
                    childFirstName: childFirstName
                )

                if data.isRegistered {
                    await MainActor.run {
                        self.childJoinedSubject.send(())
                    }
                }
            } catch {
                // 조용히 무시
            }
        }
    }

    func saveSelectedChildId(_ id: Int) {
        userSessionStorage.selectedChildId = id
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
