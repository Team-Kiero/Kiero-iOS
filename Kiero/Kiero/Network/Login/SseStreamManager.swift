//
//  SseStreamManager.swift
//  Kiero
//
//  Created by 안치욱 on 1/22/26.
//

import Foundation

import CryptoKit

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
    
    private var storedOnEvent: EventHandler?
    
    private var recentEventHashes: [String: Date] = [:]
    private let dedupeWindow: TimeInterval = 10
    private let refreshIntervalNanoseconds: UInt64 = 270 * 1_000_000_000
    
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
                    
                    guard shouldProceed else { continue }
                    
                    self.connectCandidate(token: newToken, onEvent: onEvent)
                } catch {
                    self.withLock {
                        self.isRefreshing = false
                    }
                    print("❌ [SSEManager] refresh token failed:", error)
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
        let clientID = UUID()
        
        let client = makeClient(
            id: clientID,
            token: token,
            role: .active,
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
            role: .candidate,
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
        role: ClientRole,
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
                self?.handleConnected(clientID: id, role: role)
            },
            onError: { [weak self] error in
                self?.handleError(error, clientID: id, role: role)
            }
        )
    }
    
    private func handleConnected(clientID: UUID, role: ClientRole) {
        switch role {
        case .active:
            let isValid = withLock { activeClientID == clientID && isRunning }
            guard isValid else { return }
            print("✅ [SSEManager] active connected")
            
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
        role: ClientRole
    ) {
        print("❌ [SSEManager] \(role) error:", error)
        
        switch role {
        case .active:
            let isValid = withLock { activeClientID == clientID }
            guard isValid else { return }
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
            print("⚠️ [SSEManager] candidate failed, keep existing active connection")
        }
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
}
