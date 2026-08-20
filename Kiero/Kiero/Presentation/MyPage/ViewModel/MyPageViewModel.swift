//
//  MyPageViewModel.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import Combine
import SwiftUI
import UserNotifications

final class MyPageViewModel: BaseViewModel, ObservableObject {
    
    @Published var userName: String = ""
    @Published var userImage: String? = nil
    @Published var childConnectionState: ChildConnectionState = .connected
    
    @Published var isAlarmOn: Bool = false
    @Published var showNotificationDialog: Bool = false
    
    private var pendingEnableAfterSettings: Bool = false
    
    private var externalLinks: [ExternalLinkDTO] = []
    
    let scrollToTop = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        
        print("✅ MyPageViewModel init")
        fetchUserInfo()
        fetchExternalLinks()
        bindSSE()
    }
    
    // MARK: - Notification Settings
    
    private func isOSAuthorized(_ status: UNAuthorizationStatus) -> Bool {
        status == .authorized || status == .provisional || status == .ephemeral
    }
    
    private func updateNotificationSettings(enabled: Bool) {
        AmplitudeManager.shared.setUserProperties([.pushEnabled: enabled])

        Task {
            do {
                let body = NotificationSettingsRequest(pushNotificationEnabled: enabled)
                let _: EmptyResponse = try await BaseService.shared.request(
                    endPoint: .updateNotificationSettings,
                    body: body
                )
                print("✅ 알림 설정 변경 성공: \(enabled)")
            } catch {
                print("❌ 알림 설정 변경 실패: \(error)")
                await MainActor.run {
                    self.isAlarmOn = !enabled
                }
            }
        }
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.isAlarmOn = true
                    self.updateNotificationSettings(enabled: true)
                    
                case .denied:
                    self.isAlarmOn = false
                    self.showNotificationDialog = true
                    
                case .notDetermined:
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            AmplitudeManager.shared.track(.pushPermissionResult(granted: granted, source: .myPage))
                            AmplitudeManager.shared.setUserProperties([.pushEnabled: granted])
                            DispatchQueue.main.async {
                                self.isAlarmOn = granted
                                if granted {
                                    self.updateNotificationSettings(enabled: true)
                                }
                            }
                        }
                    
                @unknown default:
                    self.isAlarmOn = false
                }
            }
        }
    }
    
    func turnOffAlarm() {
        isAlarmOn = false
        updateNotificationSettings(enabled: false)
    }
    
    func goToNotificationSettings() {
        pendingEnableAfterSettings = true
        openAppSettings()
    }

    func handleForeground() {
        if pendingEnableAfterSettings {
            resolveReturnFromSettings()
        } else {
            refreshNotificationStatus()
        }
    }

    private func resolveReturnFromSettings() {
        pendingEnableAfterSettings = false
        showNotificationDialog = false
        
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                if self.isOSAuthorized(settings.authorizationStatus) {
                    self.isAlarmOn = true
                    self.updateNotificationSettings(enabled: true)
                } else {
                    self.isAlarmOn = false
                }
            }
        }
    }
    
    func refreshNotificationStatus() {
        reconcileWithOSImmediately()
        fetchUserInfo()
    }

    private func reconcileWithOSImmediately() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                let osEnabled = self.isOSAuthorized(settings.authorizationStatus)
                if self.isAlarmOn && !osEnabled {
                    self.isAlarmOn = false
                }
            }
        }
    }
    
    // MARK: - Profile & Data
    
    func fetchUserInfo() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let profile: MyPageProfileDTO = try await BaseService.shared.request(
                    endPoint: .fetchParentInfo
                )
                
                AmplitudeManager.shared.updateUserId(profile.id)

                let settings = await UNUserNotificationCenter.current().notificationSettings()
                let isAuthorized = self.isOSAuthorized(settings.authorizationStatus)
                let shouldEnable = profile.pushNotificationEnabled && isAuthorized
                
                await MainActor.run {
                    self.userName = profile.name
                    self.userImage = profile.image
                    self.childConnectionState =
                    profile.hasPendingChildSession ? .waiting : .connected
                    
                    self.isAlarmOn = shouldEnable
                }
                
            } catch {
                let settings = await UNUserNotificationCenter.current().notificationSettings()
                let isAuthorized = self.isOSAuthorized(settings.authorizationStatus)
                
                await MainActor.run {
                    self.userName = TokenManager.shared.getUserName() ?? ""
                    self.userImage = TokenManager.shared.getProfile()
                    if self.isAlarmOn && !isAuthorized {
                        self.isAlarmOn = false
                    }
                }
                
                print("프로필 정보 조회 실패:", error)
            }
        }
    }
    
    func fetchExternalLinks() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let links: [ExternalLinkDTO] = try await BaseService.shared.request(
                    endPoint: .fetchMyPageLinks
                )
                
                await MainActor.run {
                    self.externalLinks = links
                }
            } catch {
                print("외부 링크 조회 실패:", error)
            }
        }
    }
    
    // MARK: - SSE
    
    private func bindSSE() {
        NotificationCenter.default.publisher(for: .didReceiveSseEvent)
            .compactMap { $0.object as? SseEventPayload }
            .filter { $0.eventType == "CHILD_JOINED" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                guard let self else { return }

                print("📩 [MyPageVM] CHILD_JOINED:", payload.childId ?? 0)

                AmplitudeManager.shared.setUserProperties([.childConnected: true])

                self.childConnectionState = .connected
                self.fetchUserInfo()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Logout
    
    func requestLogout() {
        LogoutService.shared.logout()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("로그아웃 완료")
                    LogoutHelper.logoutToPickRole()
                case .failure(let error):
                    print("로그아웃 실패: \(error)")
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    // MARK: - External Links & URL
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func openPrivacyPolicy() {
        openExternalLink(type: .privacyPolicy)
    }
    
    func openServiceTerms() {
        openExternalLink(type: .serviceTerms)
    }
    
    func openOpenSourceLicense() {
        openExternalLink(type: .openSourceLicense)
    }
    
    func openCustomerSupport() {
        openExternalLink(type: .customerSupport)
    }
    
    private func openExternalLink(type: ExternalLinkType) {
        guard let link = externalLinks.first(where: { $0.linkType == type })?.link else { return }
        openURL(link)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
