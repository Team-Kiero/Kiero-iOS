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
    @Published var connectedChild: Int = 0
    @Published var childConnectionState: ChildConnectionState = .connected
    
    @Published var isAlarmOn: Bool = false
    @Published var showNotificationDialog: Bool = false
    
    private var externalLinks: [ExternalLinkDTO] = []
    
    let scrollToTop = PassthroughSubject<Void, Never>()
    
    override init() {
        super.init()
        
        print("✅ MyPageViewModel init")
        fetchUserInfo()
        fetchChildCount()
        fetchExternalLinks()
        bindSSE()
    }
    
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
    
    func fetchChildCount() {
        ScheduleService.shared.fetchChildren()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("자녀 수 조회 실패: \(error)")
                }
            } receiveValue: { [weak self] children in
                self?.connectedChild = children.count
            }
            .store(in: &cancellables)
    }
    
    func fetchUserInfo() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let profile: MyPageProfileDTO = try await BaseService.shared.request(
                    endPoint: .fetchParentInfo
                )
                
                await MainActor.run {
                    self.userName = profile.name
                    self.userImage = profile.image
                    self.isAlarmOn = profile.pushNotificationEnabled
                    self.childConnectionState = profile.hasPendingChildSession ? .waiting : .connected
                }
            } catch {
                await MainActor.run {
                    self.userName = TokenManager.shared.getUserName() ?? ""
                    self.userImage = TokenManager.shared.getProfile()
                    print("프로필 정보 조회 실패:", error)
                }
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
    
    private func bindSSE() {
        NotificationCenter.default.publisher(for: .didReceiveSseEvent)
            .compactMap { $0.object as? SseEventPayload }
            .filter { $0.eventType == "CHILD_JOINED" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] payload in
                guard let self else { return }

                print("📩 [MyPageVM] CHILD_JOINED:", payload.childId ?? 0)

                self.childConnectionState = .connected

                self.fetchChildCount()
                self.fetchUserInfo()
            }
            .store(in: &cancellables)
    }
    
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                guard let self else { return }
                
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    self.isAlarmOn = true
                    
                case .denied:
                    self.isAlarmOn = false
                    self.showNotificationDialog = true
                    
                case .notDetermined:
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            DispatchQueue.main.async {
                                self.isAlarmOn = granted
                                
                                if !granted {
                                    self.showNotificationDialog = true
                                }
                            }
                        }
                    
                @unknown default:
                    self.isAlarmOn = false
                    self.showNotificationDialog = true
                }
            }
        }
    }
    
    func refreshNotificationStatus() {
        fetchUserInfo()
    }
    
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
