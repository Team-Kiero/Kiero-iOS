//
//  ChildManageViewModel.swift
//  Kiero
//
//  Created by 안치욱 on 5/31/26.
//

import Combine
import Foundation

final class ChildManageViewModel: BaseViewModel, ObservableObject {
    
    @Published var connectionState: ChildConnectionState = .connected
    @Published var childName: String = ""
    @Published var inviteCode: String = ""
    @Published var remainingText: String = "00:00"
    @Published var isExpired: Bool = false
    
    private var childLastName: String = ""
    private var childFirstName: String = ""
    
    private let expiresIn: TimeInterval
    private var expiresAt: Date?
    
    private var timerCancellable: AnyCancellable?
    
    init(expiresIn: TimeInterval = 10 * 60) {
        self.expiresIn = expiresIn
        super.init()

        fetchChild()
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
                    self.connectionState = .connected
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
                
                await MainActor.run {
                    self.inviteCode = data.code
                    self.connectionState = .waiting
                    self.expiresAt = Date().addingTimeInterval(self.expiresIn)
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
            timerCancellable?.cancel()
            timerCancellable = nil
            return
        }
        
        remainingText = Self.format(seconds: remaining)
        isExpired = false
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

                self.timerCancellable?.cancel()
                self.timerCancellable = nil

                self.inviteCode = ""
                self.remainingText = "00:00"
                self.isExpired = false
                self.expiresAt = nil
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
