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
    let childName: String
    let inviteCode: String

    private let expiresAt: Date

    private let remainingTextSubject = CurrentValueSubject<String, Never>("10:00")
    var remainingText: AnyPublisher<String, Never> {
        remainingTextSubject.eraseToAnyPublisher()
    }

    private let isExpiredSubject = CurrentValueSubject<Bool, Never>(false)
    var isExpired: AnyPublisher<Bool, Never> {
        isExpiredSubject.eraseToAnyPublisher()
    }

    private var timerCancellable: AnyCancellable?

    init(
        parentName: String,
        profileURL: String,
        childName: String,
        inviteCode: String,
        issuedAt: Date
    ) {
        self.parentName = parentName
        self.profileURL = profileURL
        self.childName = childName
        self.inviteCode = inviteCode
        self.expiresAt = issuedAt.addingTimeInterval(10 * 60)

        super.init()
        startCountdown()
    }

    private func startCountdown() {
        tick()

        timerCancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] (_: Date) in
                self?.tick()
            }
    }

    private func tick() {
        let remaining = Int(expiresAt.timeIntervalSinceNow.rounded(.down))

        if remaining <= 0 {
            remainingTextSubject.send("00:00")
            isExpiredSubject.send(true)
            timerCancellable?.cancel()
            timerCancellable = nil
            return
        }

        let m = remaining / 60
        let s = remaining % 60
        remainingTextSubject.send(String(format: "%02d:%02d", m, s))
        isExpiredSubject.send(false)
    }

    deinit {
        timerCancellable?.cancel()
    }
}
