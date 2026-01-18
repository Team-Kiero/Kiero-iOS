//
//  TokenRefresher.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//

import Combine
import Foundation

final class TokenRefresher {

    private let repo: AuthRepositoryType
    private let lock = NSLock()
    private var inFlight: AnyPublisher<Void, NetworkError>?

    init(repo: AuthRepositoryType) {
        self.repo = repo
    }

    func refreshAccessToken() -> AnyPublisher<Void, NetworkError> {
        lock.lock()
        if let inFlight {
            lock.unlock()
            return inFlight
        }
        lock.unlock()
        let pub = repo.reissueAccessToken()
            .map { newAccess in
                TokenManager.shared.saveAccessToken(newAccess)
            }
            .map { _ in () }
            .handleEvents(receiveCompletion: { [weak self] _ in
                guard let self else { return }
                self.lock.lock()
                self.inFlight = nil
                self.lock.unlock()
            })
            .share()
            .eraseToAnyPublisher()
        lock.lock()
        inFlight = pub
        lock.unlock()

        return pub
    }
}
