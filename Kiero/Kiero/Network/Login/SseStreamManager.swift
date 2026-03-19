//
//  SseStreamManager.swift
//  Kiero
//
//  Created by 안치욱 on 1/22/26.
//

import Foundation

final class SseStreamManager {
    
    var onRefreshWillStart: (() -> Void)?
    var onReconnected: (() -> Void)?
    
    static let shared = SseStreamManager(sseURL: Config.sseURL)
    
    private let sseURL: URL
    private var client: SseClient?
    
    private var sseAccessToken: String?
    private var refreshTask: Task<Void, Never>?
    private var isRunning = false
    
    private var isConnecting = false
    
    init(sseURL: URL) {
        self.sseURL = sseURL
    }
    
    /// 최초 토큰으로 즉시 연결 + 이후 5분마다 토큰 재발급/재연결
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
        
        // 최초 연결
        Task { @MainActor [weak self] in
            guard let self else { return }
            print("✅ [SSEManager] connect() will be called (initial)")
            self.connect(onEvent: onEvent)
        }
        
        // 5분마다 토큰 갱신 + 재연결
        refreshTask?.cancel()
        refreshTask = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                // ✅ 서버 스펙: 5분마다 재발급 필요
                try? await Task.sleep(nanoseconds: 5 * 60 * 1_000_000_000)
                
                // ✅ (3번 방식) 재발급 시작 훅 — “공백 중 이벤트 유실” 대비 조회를 여기서 1회
                self.onRefreshWillStart?()
                
                do {
                    let newToken = try await TokenRefresher.shared.reissueSseAccessToken()
                    self.sseAccessToken = newToken
                    
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        print("✅ [SSEManager] connect() will be called (refresh)")
                        self.connect(onEvent: onEvent)
                    }
                } catch {
                    // 재발급 실패 정책: 로그/재시도/stop 등
                    // 여기서는 다음 루프에서 다시 시도
                    print("❌ [SSEManager] refresh token failed:", error)
                }
            }
        }
    }
    
    @MainActor
    private func connect(onEvent: @escaping (SseEventPayload) -> Void) {
        guard isRunning else { return }
        guard isConnecting == false else {
            print("⚠️ [SSEManager] connect skipped (already connecting)")
            return
        }
        isConnecting = true

        client?.disconnect()

        client = SseClient(
            url: sseURL,
            tokenProvider: { [weak self] in
                return self?.sseAccessToken
            },
            onEvent: { payload in
                NotificationCenter.default.post(
                    name: .sseEventReceived,
                    object: nil,
                    userInfo: ["payload": payload]
                )
                onEvent(payload)
            },
            onConnected: { [weak self] in
                guard let self else { return }
                print("✅ [SSEManager] onConnected -> onReconnected")
                self.onReconnected?()
                self.isConnecting = false
            },
            onError: { [weak self] error in
                print("❌ [SSEClient] error:", error)
                self?.isConnecting = false
            }
        )

        client?.connect()
    }
    
    func pause() {
        client?.disconnect()
        client = nil
        isRunning = false
        isConnecting = false
    }
    
    func stop() {
        pause()
        refreshTask?.cancel()
        refreshTask = nil
        sseAccessToken = nil
    }
}
