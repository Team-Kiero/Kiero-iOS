//
//  MySpaceView.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import Combine
import SwiftUI
import UserNotifications

struct MySpaceView: View {
    @State private var isAlarmOn = UserDefaults.standard.bool(forKey: "child_pushNotificationEnabled")
    @State private var showNotificationDialog = false
    @State private var showLogoutDialog = false
    @State private var showTerms = false
    var onNavigateToWishRoom: (() -> Void)?
    
    private let userName = TokenManager.shared.getFirstName() ?? "꾸비"
    var isPreview = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.kBlack.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    HStack(spacing: 0) {
                        Image(.icKidProfile)
                            .resizable()
                            .frame(width: 40, height: 40)
                        
                        Text(userName)
                            .font(Font(UIFont.title3_16_SB))
                            .foregroundStyle(.white)
                        
                        Text("의 공간")
                            .font(Font(UIFont.title3_16_SB))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 16)
                    
                    WishSpaceCardView {
                        onNavigateToWishRoom?()
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    Rectangle()
                        .fill(.gray900)
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                        .padding(.top, 17)
                    
                    TurnOnAlarmView(isOn: Binding(
                        get: { isAlarmOn },
                        set: { newValue in
                            if isPreview {
                                isAlarmOn = newValue
                            } else if newValue {
                                checkNotificationPermission()
                            } else {
                                isAlarmOn = false
                                updateNotificationSettings(enabled: false)
                            }
                        }
                    ))
                    .padding(.horizontal, 16)
                    .padding(.top, 17)
                    
                    VStack(spacing: 0) {
                        MenuListItem(title: "키어로 이용 약속") {
                            showTerms = true
                        }
                        MenuListItem(title: "키어로 나가기") {
                            showLogoutDialog = true
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    Text("앱 버전 v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundStyle(.gray500)
                        .padding(.leading, 25)
                        .padding(.top, 13)
                    
                    Spacer()
                }
                .padding(.top, 59)
                .ignoresSafeArea(edges: .top)
                
                if showNotificationDialog {
                    Color.kBlack.opacity(0.75)
                        .ignoresSafeArea()
                        .onTapGesture { showNotificationDialog = false }
                    
                    DialogBoxView(
                        state: .childNotification,
                        isPresented: $showNotificationDialog,
                        onConfirm: {
                            openAppSettings()
                        }
                    )
                    .padding(.horizontal, 16)
                    .zIndex(1)
                }
                
                if showLogoutDialog {
                    Color.kBlack.opacity(0.75)
                        .ignoresSafeArea()
                        .onTapGesture { showLogoutDialog = false }
                    
                    DialogBoxView(
                        state: .childLogout,
                        isPresented: $showLogoutDialog,
                        onConfirm: {
                            performLogout()
                        }
                    )
                    .padding(.horizontal, 16)
                    .zIndex(1)
                }
            }
            .navigationDestination(isPresented: $showTerms) {
                TermsView()
            }
            .navigationBarHidden(true)
            .onAppear { fetchProfile() }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                fetchProfile()
            }
            .onChange(of: isAlarmOn) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "child_pushNotificationEnabled")
            }
        }
    }
}

// MARK: - Actions

private extension MySpaceView {
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    isAlarmOn = true
                    updateNotificationSettings(enabled: true)
                case .denied:
                    isAlarmOn = false
                    showNotificationDialog = true
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        AmplitudeManager.shared.track(.pushPermissionResult, properties: [
                            AnalyticsEventProperty.granted: granted,
                            AnalyticsEventProperty.source: "my_space"
                        ])
                        AmplitudeManager.shared.setUserProperties([.pushEnabled: granted])
                        DispatchQueue.main.async {
                            isAlarmOn = granted
                            if granted {
                                updateNotificationSettings(enabled: true)
                            } else {
                                showNotificationDialog = true
                            }
                        }
                    }
                @unknown default:
                    showNotificationDialog = true
                }
            }
        }
    }
    
    func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let osEnabled = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                
                if isAlarmOn != osEnabled {
                    setAlarmSilently(osEnabled)
                    updateNotificationSettings(enabled: osEnabled)
                }
            }
        }
    }
    
    func fetchProfile() {
        WishWellService().fetchMyInfo()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { info in
                setAlarmSilently(info.pushNotificationEnabled)
                refreshNotificationStatus()
            }
            .store(in: &StaticCancellables.bag)
    }
    
    func setAlarmSilently(_ value: Bool) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            isAlarmOn = value
        }
    }
    
    func updateNotificationSettings(enabled: Bool) {
        AmplitudeManager.shared.setUserProperties([.pushEnabled: enabled])

        Task {
            do {
                let body = NotificationSettingsRequest(pushNotificationEnabled: enabled)
                let _: EmptyResponse = try await BaseService.shared.request(
                    endPoint: .updateNotificationSettings,
                    body: body
                )
                print("✅ [자녀] 알림 설정 변경 성공: \(enabled)")
            } catch {
                print("❌ [자녀] 알림 설정 변경 실패: \(error)")
                await MainActor.run {
                    isAlarmOn = !enabled
                }
            }
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func performLogout() {
        LogoutService.shared.logout()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .finished = completion {
                    LogoutHelper.logoutToPickRole()
                }
            } receiveValue: { _ in }
            .store(in: &StaticCancellables.bag)
    }
}

private enum StaticCancellables {
    static var bag = Set<AnyCancellable>()
}
