//
//  ChildManageViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 5/31/26.
//

import Combine
import Foundation

enum ChildManageRoute {
    case toast(String)
}

private enum InviteSessionKey {
    static let code = "pendingInviteCode"
    static let expiresAt = "pendingInviteExpiresAt"
}

final class ChildManageViewModel: BaseViewModel, ObservableObject {
    
    @Published var connectionState: ChildConnectionState = .connected
    @Published var childName: String = ""
    @Published var inviteCode: String = ""
    @Published var remainingText: String = "00:00"
    @Published var isExpired: Bool = false
    
    private let routeSubject = PassthroughSubject<ChildManageRoute, Never>()
    var route: AnyPublisher<ChildManageRoute, Never> {
        routeSubject.eraseToAnyPublisher()
    }
    
    private var childLastName: String = ""
    private var childFirstName: String = ""
    
    private let expiresIn: TimeInterval
    private var expiresAt: Date?
    
    private var timerCancellable: AnyCancellable?
    
    init(
        initialConnectionState: ChildConnectionState,
        expiresIn: TimeInterval = 10 * 60
    ) {
        self.connectionState = initialConnectionState
        self.expiresIn = expiresIn
        super.init()
        
        fetchChild()
        restoreInviteSessionIfNeeded()
        bindSSE()
    }
    
    func fetchChild() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let children: [ChildrenData] = try await BaseService.shared.request(
                    endPoint: .fetchChildren
                )
                
                guard let child = children.first else { return }
                
                await MainActor.run {
                    self.childLastName = child.childLastName
                    self.childFirstName = child.childFirstName
                    self.childName = "\(child.childLastName)\(child.childFirstName)"
                }
            } catch {
                print("자녀 조회 실패:", error)
            }
        }
    }
    
    func reissueInviteCode() {
        guard childLastName.isEmpty == false,
              childFirstName.isEmpty == false
        else { return }
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let req = InviteCodeRequest(
                    childLastName: childLastName,
                    childFirstName: childFirstName
                )
                
                let data: InviteCodeData = try await BaseService.shared.request(
                    endPoint: .postInviteCode,
                    body: req
                )
                
                AmplitudeManager.shared.track(.inviteCodeCreated, properties: [
                    AnalyticsEventProperty.inviteCodeHash: AnalyticsIdentity.hashed(data.code),
                    AnalyticsEventProperty.source: "child_manage"
                ])

                await MainActor.run {
                    let expiresAt = Date().addingTimeInterval(self.expiresIn)

                    self.inviteCode = data.code
                    self.connectionState = .waiting
                    self.expiresAt = expiresAt

                    UserDefaults.standard.set(data.code, forKey: InviteSessionKey.code)
                    UserDefaults.standard.set(expiresAt.timeIntervalSince1970, forKey: InviteSessionKey.expiresAt)

                    self.restartCountdown()
                }
            } catch {
                print("연결 코드 재발급 실패:", error)
            }
        }
    }
    
    func refreshInviteCode() {
        timerCancellable?.cancel()
        timerCancellable = nil
        reissueInviteCode()
    }
    
    private func restartCountdown() {
        timerCancellable?.cancel()
        timerCancellable = nil
        
        isExpired = false
        remainingText = Self.format(seconds: Int(expiresIn))
        
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
        guard let expiresAt else { return }
        
        let remaining = Int(expiresAt.timeIntervalSinceNow.rounded(.down))
        
        if remaining <= 0 {
            remainingText = "00:00"
            isExpired = true
            clearInviteSession()
            timerCancellable?.cancel()
            timerCancellable = nil
            return
        }
        
        remainingText = Self.format(seconds: remaining)
        isExpired = false
    }
    
    private func restoreInviteSessionIfNeeded() {
        guard connectionState == .waiting else { return }
        
        guard let code = UserDefaults.standard.string(forKey: InviteSessionKey.code) else { return }
        
        let timestamp = UserDefaults.standard.double(forKey: InviteSessionKey.expiresAt)
        guard timestamp > 0 else { return }
        
        let restoredExpiresAt = Date(timeIntervalSince1970: timestamp)
        
        guard restoredExpiresAt > Date() else {
            clearInviteSession()
            isExpired = true
            remainingText = "00:00"
            return
        }
        
        inviteCode = code
        expiresAt = restoredExpiresAt
        startCountdown()
    }
    
    private func clearInviteSession() {
        UserDefaults.standard.removeObject(forKey: InviteSessionKey.code)
        UserDefaults.standard.removeObject(forKey: InviteSessionKey.expiresAt)
    }
    
    private func bindSSE() {
        NotificationCenter.default.publisher(for: .didReceiveSseEvent)
            .compactMap { $0.object as? SseEventPayload }
            .filter { $0.eventType == "CHILD_JOINED" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                guard let self else { return }

                print("📩 [ChildManageVM] CHILD_JOINED:", payload.childId ?? 0)

                self.connectionState = .connected
                self.clearInviteSession()
                self.timerCancellable?.cancel()
                self.timerCancellable = nil

                self.inviteCode = ""
                self.remainingText = "00:00"
                self.isExpired = false
                self.expiresAt = nil
                self.routeSubject.send(.toast("자녀 연결이 완료되었습니다."))
            }
            .store(in: &cancellables)
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
