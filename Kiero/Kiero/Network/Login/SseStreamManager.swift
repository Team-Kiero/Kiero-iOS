//
//  SseStreamManager.swift
//  Kiero
//
//  Created by 안치욱 on 1/22/26.
//

import Foundation

final class SseStreamManager {

    private let sseURL: URL
    private var client: SseClient?

    private var sseAccessToken: String?
    private var refreshTask: Task<Void, Never>?
    private var isRunning = false

    init(sseURL: URL) {
        self.sseURL = sseURL
    }

    /// 최초 토큰으로 바로 연결 + 이후 5분마다 토큰 재발급/재연결
    func startIfNeeded(
        initialToken: String,
        onEvent: @escaping (SseEventPayload) -> Void
    ) {
        print("✅ [SSEManager] startIfNeeded called, isRunning:", isRunning)
        guard !isRunning else {
            print("⚠️ [SSEManager] already running")
            return
        }
        isRunning = true

        sseAccessToken = initialToken

        Task { @MainActor in
            print("✅ [SSEManager] connect() will be called")
            self.connect(onEvent: onEvent)
        }

        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)

                do {
                    let newToken = try await BaseService.shared.reissueSseAccessToken()
                    self.sseAccessToken = newToken

                    await MainActor.run {
                        self.connect(onEvent: onEvent) // 재연결
                    }
                } catch {
                    // 재발급 실패 정책: 로그/재시도/stop 등
                    // 여기서는 다음 루프에서 재시도하도록 둠
                }
            }
        }
    }

    @MainActor
    private func connect(onEvent: @escaping (SseEventPayload) -> Void) {
        client?.disconnect()

        client = SseClient(
            url: sseURL,
            tokenProvider: { [weak self] in self?.sseAccessToken },
            onEvent: onEvent,
            onError: { error in
                // 필요하면 재연결/backoff
                // print("SSE error:", error)
            }
        )
        client?.connect()
    }

    func stop() {
        isRunning = false
        refreshTask?.cancel()
        refreshTask = nil
        client?.disconnect()
        client = nil
        sseAccessToken = nil
    }
}

//import Foundation
//
//final class SseStreamManager {
//
//    private let sseURL: URL
//    private var client: SseClient?
//
//    private var sseAccessToken: String?
//    private var refreshTask: Task<Void, Never>?
//
//    private var isRunning = false
//
//    init(sseURL: URL) {
//        self.sseURL = sseURL
//    }
//
//    func startIfNeeded(onEvent: @escaping (SseEventPayload) -> Void) {
//        guard !isRunning else { return }
//        isRunning = true
//
//        refreshTask?.cancel()
//        refreshTask = Task { [weak self] in
//            guard let self else { return }
//
//            while !Task.isCancelled {
//                do {
//                    // 1) refreshToken(Cookie)로 SSE 토큰 발급
//                    let token = try await BaseService.shared.reissueSseAccessToken()
//                    self.sseAccessToken = token
//
//                    // 2) 새 토큰으로 SSE 연결(재연결 포함)
//                    await MainActor.run {
//                        self.connect(onEvent: onEvent)
//                    }
//                } catch {
//                    // 실패 시 isRunning 유지할지, stop할지 정책 선택 가능
//                }
//
//                // 5분마다 재발급
//                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)
//            }
//        }
//    }
//
//    @MainActor
//    private func connect(onEvent: @escaping (SseEventPayload) -> Void) {
//        client?.disconnect()
//
//        let tokenProvider = { [weak self] in self?.sseAccessToken }
//
//        client = SseClient(
//            url: sseURL,
//            tokenProvider: tokenProvider,
//            onEvent: onEvent,
//            onError: { _ in
//                // 필요 시 재연결 전략 추가 가능
//            }
//        )
//
//        client?.connect()
//    }
//
//    func stop() {
//        isRunning = false
//        refreshTask?.cancel()
//        refreshTask = nil
//        client?.disconnect()
//        client = nil
//        sseAccessToken = nil
//    }
//}
