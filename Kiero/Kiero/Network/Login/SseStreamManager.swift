//
//  SseStreamManager.swift
//  Kiero
//
//  Created by 안치욱 on 1/22/26.
//

import CryptoKit
import Foundation

final class SseStreamManager {
    
    typealias EventHandler = (SseEventPayload) -> Void
    
    var onRefreshWillStart: (() -> Void)?
    var onReconnected: (() -> Void)?
    
    static let shared = SseStreamManager(sseURL: Config.sseURL)
    
    private let sseURL: URL
    private let lock = NSLock()
    
    private var activeClient: SseClient?
    private var candidateClient: SseClient?
    
    private var activeClientID: UUID?
    private var candidateClientID: UUID?
    
    private var sseAccessToken: String?
    private var refreshTask: Task<Void, Never>?
    
    private var isRunning = false
    private var isRefreshing = false
    private var isRecoveringActive = false
    private var recoveryAttempt = 0
    private var activeFailedDuringRefresh = false
    
    private var storedOnEvent: EventHandler?
    
    private var recentEventHashes: [String: Date] = [:]
    private let dedupeWindow: TimeInterval = 10
    private let refreshIntervalNanoseconds: UInt64 = 270 * 1_000_000_000
    private let maxRecoveryDelaySeconds = 30
    
    var isActive: Bool {
        withLock { isRunning }
    }
    
    init(sseURL: URL) {
        self.sseURL = sseURL
    }
    
    func startIfNeeded(
        initialToken: String,
        onEvent: @escaping EventHandler
    ) {
        let shouldStart: Bool = withLock {
            guard !isRunning else {
                print("⚠️ [SSEManager] already running")
                return false
            }
            
            isRunning = true
            sseAccessToken = initialToken
            storedOnEvent = onEvent
            return true
        }
        
        guard shouldStart else { return }
        
        print("✅ [SSEManager] startIfNeeded")
        connectActive(token: initialToken, onEvent: onEvent)
        startRefreshLoop(onEvent: onEvent)
    }
    
    func resume() {
        let onEvent: EventHandler? = withLock {
            guard !isRunning else { return nil }
            guard let storedOnEvent else { return nil }
            isRunning = true
            return storedOnEvent
        }
        
        guard let onEvent else { return }
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let newToken = try await TokenRefresher.shared.reissueSseAccessToken()
                
                let shouldProceed = self.withLock { () -> Bool in
                    guard self.isRunning else { return false }
                    self.sseAccessToken = newToken
                    return true
                }
                
                guard shouldProceed else { return }
                
                self.connectActive(token: newToken, onEvent: onEvent)
                self.startRefreshLoop(onEvent: onEvent)
            } catch {
                print("❌ [SSEManager] resume failed:", error)
                
                if self.isTokenRejected(error) {
                    self.pause()
                    return
                }
                
                self.startRefreshLoop(onEvent: onEvent)
                self.scheduleRecovery(token: nil, onEvent: onEvent)
            }
        }
    }
    
    func pause() {
        let clients = withLock { () -> (SseClient?, SseClient?, Task<Void, Never>?) in
            let active = activeClient
            let candidate = candidateClient
            let task = refreshTask
            
            activeClient = nil
            candidateClient = nil
            activeClientID = nil
            candidateClientID = nil
            refreshTask = nil
            
            isRunning = false
            isRefreshing = false
            isRecoveringActive = false
            recoveryAttempt = 0
            activeFailedDuringRefresh = false
            
            return (active, candidate, task)
        }
        
        clients.0?.disconnect()
        clients.1?.disconnect()
        clients.2?.cancel()
    }
    
    func stop() {
        pause()
        
        withLock {
            sseAccessToken = nil
            recentEventHashes.removeAll()
        }
    }
    
    private func startRefreshLoop(onEvent: @escaping EventHandler) {
        let oldTask = withLock { () -> Task<Void, Never>? in
            let old = refreshTask
            refreshTask = nil
            return old
        }
        oldTask?.cancel()
        
        let task = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                do {
                    try await Task.sleep(nanoseconds: self.refreshIntervalNanoseconds)
                } catch {
                    return
                }
                
                let canRefresh = self.withLock { () -> Bool in
                    guard self.isRunning else { return false }
                    guard self.isRefreshing == false else {
                        print("⚠️ [SSEManager] refresh skipped (already refreshing)")
                        return false
                    }
                    
                    self.isRefreshing = true
                    return true
                }
                
                guard canRefresh else { continue }
                
                DispatchQueue.main.async { [weak self] in
                    self?.onRefreshWillStart?()
                }
                
                let retryDelays: [UInt64] = [
                    0,
                    3 * 1_000_000_000,
                    5 * 1_000_000_000
                ]
                
                var refreshed = false
                
                for (index, delay) in retryDelays.enumerated() {
                    if delay > 0 {
                        do {
                            try await Task.sleep(nanoseconds: delay)
                        } catch {
                            return
                        }
                    }
                    
                    do {
                        let newToken = try await TokenRefresher.shared.reissueSseAccessToken()
                        
                        let shouldProceed = self.withLock { () -> Bool in
                            guard self.isRunning else {
                                self.isRefreshing = false
                                return false
                            }
                            
                            self.sseAccessToken = newToken
                            return true
                        }
                        
                        guard shouldProceed else { break }
                        
                        self.connectCandidate(token: newToken, onEvent: onEvent)
                        refreshed = true
                        break
                    } catch {
                        print("❌ [SSEManager] refresh retry \(index + 1) failed:", error)
                    }
                }
                
                if !refreshed {
                    self.withLock {
                        self.isRefreshing = false
                    }
                    print("❌ [SSEManager] refresh failed after retries")
                    self.recoverActiveIfFailedDuringRefresh(tokenRejected: false, onEvent: onEvent)
                }
            }
        }
        
        withLock {
            refreshTask = task
        }
    }
    
    private func connectActive(
        token: String,
        onEvent: @escaping EventHandler
    ) {
        let oldActive = withLock { () -> SseClient? in
            let old = activeClient
            activeClient = nil
            activeClientID = nil
            return old
        }
        oldActive?.disconnect()
        
        let clientID = UUID()
        
        let client = makeClient(
            id: clientID,
            token: token,
            onEvent: onEvent
        )
        
        withLock {
            activeClientID = clientID
            activeClient = client
        }
        
        client.connect()
    }
    
    private func connectCandidate(
        token: String,
        onEvent: @escaping EventHandler
    ) {
        let oldCandidate = withLock { () -> SseClient? in
            guard isRunning else {
                isRefreshing = false
                return nil
            }
            
            let old = candidateClient
            candidateClient = nil
            candidateClientID = nil
            return old
        }
        oldCandidate?.disconnect()
        
        let clientID = UUID()
        let client = makeClient(
            id: clientID,
            token: token,
            onEvent: onEvent
        )
        
        withLock {
            guard isRunning else {
                isRefreshing = false
                return
            }
            
            candidateClientID = clientID
            candidateClient = client
        }
        
        client.connect()
    }
    
    private func makeClient(
        id: UUID,
        token: String,
        onEvent: @escaping EventHandler
    ) -> SseClient {
        SseClient(
            url: sseURL,
            tokenProvider: { token },
            onEvent: { [weak self] payload in
                guard let self else { return }
                
                if self.shouldSkipDuplicateEvent(payload) {
                    print("⚠️ [SSEManager] duplicate event skipped")
                    return
                }
                
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .sseEventReceived,
                        object: nil,
                        userInfo: ["payload": payload]
                    )
                    onEvent(payload)
                }
            },
            onConnected: { [weak self] in
                self?.handleConnected(clientID: id)
            },
            onError: { [weak self] error in
                self?.handleError(error, clientID: id, onEvent: onEvent)
            }
        )
    }
    
    private func handleConnected(clientID: UUID) {
        // 갱신으로 승격된 연결도 현재 역할로 처리하도록 콜백 시점의 ID로 역할 판단
        guard let role = withLock({ currentRole(of: clientID) }) else { return }
        
        switch role {
        case .active:
            let shouldNotifyReconnect = withLock { () -> Bool in
                guard activeClientID == clientID, isRunning else { return false }
                
                let wasRecovering = recoveryAttempt > 0
                recoveryAttempt = 0
                
                print("✅ [SSEManager] active connected")
                return wasRecovering
            }
            
            if shouldNotifyReconnect {
                DispatchQueue.main.async { [weak self] in
                    self?.onReconnected?()
                }
            }
            
        case .candidate:
            let previousActive: SseClient? = withLock {
                guard isRunning else { return nil }
                guard candidateClientID == clientID else { return nil }
                
                print("✅ [SSEManager] candidate connected -> promote to active")
                
                let oldActive = activeClient
                activeClient = candidateClient
                activeClientID = candidateClientID
                
                candidateClient = nil
                candidateClientID = nil
                isRefreshing = false
                recoveryAttempt = 0
                activeFailedDuringRefresh = false
                
                return oldActive
            }
            
            guard previousActive != nil else { return }
            
            previousActive?.disconnect()
            
            DispatchQueue.main.async { [weak self] in
                self?.onReconnected?()
            }
        }
    }
    
    private func handleError(
        _ error: Error,
        clientID: UUID,
        onEvent: @escaping EventHandler
    ) {
        // 갱신으로 승격된 연결도 현재 역할로 처리하도록 콜백 시점의 ID로 역할 판단
        guard let role = withLock({ currentRole(of: clientID) }) else { return }
        
        print("❌ [SSEManager] \(role) error:", error)
        
        switch role {
        case .active:
            let recoveryContext: ActiveRecoveryContext? = withLock {
                guard activeClientID == clientID else { return nil }
                guard isRunning else { return nil }
                
                if isRefreshing {
                    // 새 연결이 승격되면 대체되고, 실패하면 그때 복구를 시작
                    print("⚠️ [SSEManager] active error while refresh in progress, defer recovery")
                    activeFailedDuringRefresh = true
                    return nil
                }
                
                let currentToken = isTokenRejected(error) ? nil : sseAccessToken
                let oldActive = activeClient
                activeClient = nil
                activeClientID = nil
                
                return ActiveRecoveryContext(
                    currentToken: currentToken,
                    onEvent: onEvent,
                    oldClient: oldActive
                )
            }
            
            guard let recoveryContext else { return }
            recoveryContext.oldClient?.disconnect()
            
            scheduleRecovery(token: recoveryContext.currentToken, onEvent: recoveryContext.onEvent)
        case .candidate:
            let candidateToDisconnect: SseClient? = withLock {
                guard candidateClientID == clientID else { return nil }
                
                let client = candidateClient
                candidateClient = nil
                candidateClientID = nil
                isRefreshing = false
                
                return client
            }
            
            candidateToDisconnect?.disconnect()
            print("⚠️ [SSEManager] candidate failed")
            
            recoverActiveIfFailedDuringRefresh(tokenRejected: isTokenRejected(error), onEvent: onEvent)
        }
    }
    
    private func currentRole(of clientID: UUID) -> ClientRole? {
        if activeClientID == clientID { return .active }
        if candidateClientID == clientID { return .candidate }
        return nil
    }
    
    private func recoverActiveIfFailedDuringRefresh(tokenRejected: Bool, onEvent: @escaping EventHandler) {
        let recoveryContext: ActiveRecoveryContext? = withLock {
            guard isRunning, activeFailedDuringRefresh else { return nil }
            
            activeFailedDuringRefresh = false
            
            let oldActive = activeClient
            activeClient = nil
            activeClientID = nil
            
            return ActiveRecoveryContext(
                currentToken: tokenRejected ? nil : sseAccessToken,
                onEvent: onEvent,
                oldClient: oldActive
            )
        }
        
        guard let recoveryContext else { return }
        recoveryContext.oldClient?.disconnect()
        
        print("🔄 [SSEManager] active failed during refresh, start recovery")
        scheduleRecovery(token: recoveryContext.currentToken, onEvent: recoveryContext.onEvent)
    }
    
    private func scheduleRecovery(token: String?, onEvent: @escaping EventHandler) {
        let shouldStart = withLock { () -> Bool in
            guard isRunning, !isRecoveringActive else { return false }
            isRecoveringActive = true
            return true
        }
        
        guard shouldStart else { return }
        
        Task { [weak self] in
            await self?.recoverActiveConnection(token: token, onEvent: onEvent)
        }
    }
    
    private func recoverActiveConnection(token initialToken: String?, onEvent: @escaping EventHandler) async {
        var token = initialToken
        
        while true {
            let attempt = withLock { recoveryAttempt }
            try? await Task.sleep(nanoseconds: recoveryDelayNanoseconds(for: attempt))
            
            let canRecover = withLock { () -> Bool in
                guard isRunning, activeClient == nil else {
                    isRecoveringActive = false
                    return false
                }
                return true
            }
            
            guard canRecover else { return }
            
            if token?.isEmpty ?? true {
                do {
                    print("🔄 [SSEManager] reissue token for recovery (attempt \(attempt + 1))")
                    token = try await TokenRefresher.shared.reissueSseAccessToken()
                } catch {
                    if isTokenRejected(error) {
                        print("❌ [SSEManager] token reissue rejected, stop recovery:", error)
                        pause()
                        return
                    }
                    
                    print("❌ [SSEManager] token reissue failed, retry later:", error)
                    withLock { recoveryAttempt += 1 }
                    continue
                }
            }
            
            guard let validToken = token else { continue }
            
            let shouldConnect = withLock { () -> Bool in
                guard isRunning, activeClient == nil else {
                    isRecoveringActive = false
                    return false
                }
                
                sseAccessToken = validToken
                recoveryAttempt += 1
                isRecoveringActive = false
                return true
            }
            
            guard shouldConnect else { return }
            
            print("🔄 [SSEManager] recover active connection (attempt \(attempt + 1))")
            connectActive(token: validToken, onEvent: onEvent)
            return
        }
    }
    
    private func recoveryDelayNanoseconds(for attempt: Int) -> UInt64 {
        let seconds = min(2 << min(attempt, 4), maxRecoveryDelaySeconds)
        return UInt64(seconds) * 1_000_000_000
    }
    
    private func isTokenRejected(_ error: Error) -> Bool {
        guard case NetworkError.clientError(let statusCode) = error else { return false }
        return statusCode == 401 || statusCode == 403
    }
    
    private func shouldSkipDuplicateEvent(_ payload: SseEventPayload) -> Bool {
        withLock {
            cleanupExpiredEventHashesLocked()
            
            let hash = makeEventHash(from: payload)
            if recentEventHashes[hash] != nil {
                return true
            }
            
            recentEventHashes[hash] = Date()
            return false
        }
    }
    
    private func cleanupExpiredEventHashesLocked() {
        let now = Date()
        recentEventHashes = recentEventHashes.filter {
            now.timeIntervalSince($0.value) < dedupeWindow
        }
    }
    
    private func makeEventHash(from payload: SseEventPayload) -> String {
        let raw = String(describing: payload)
        let digest = SHA256.hash(data: Data(raw.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    @discardableResult
    private func withLock<T>(_ work: () -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return work()
    }
}

private extension SseStreamManager {
    enum ClientRole: CustomStringConvertible {
        case active
        case candidate
        
        var description: String {
            switch self {
            case .active: return "active"
            case .candidate: return "candidate"
            }
        }
    }
    
    struct ActiveRecoveryContext {
        let currentToken: String?
        let onEvent: EventHandler
        let oldClient: SseClient?
    }
}
