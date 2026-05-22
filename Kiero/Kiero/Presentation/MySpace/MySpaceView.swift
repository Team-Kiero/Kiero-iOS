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
    @State private var isAlarmOn = false
    @State private var showNotificationDialog = false
    @State private var showLogoutDialog = false
    
    private let userName = TokenManager.shared.getFirstName() ?? "꾸비"
    var isPreview = false
    
    let onWishSpaceTap: () -> Void
    let onTermsTap: () -> Void
    let onLogoutConfirm: () -> Void
    
    var body: some View {
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
                .padding(.top, 15)
                
                WishSpaceCardView {
                    onWishSpaceTap()
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
                        }
                    }
                ))
                .padding(.horizontal, 16)
                .padding(.top, 17)
                
                VStack(spacing: 0) {
                    MenuListItem(title: "키어로 이용 약속") {
                        onTermsTap()
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
            
            if showNotificationDialog {
                Color.kBlack.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture { showNotificationDialog = false }
                
                DialogBoxWrapper(
                    state: .childNotification,
                    isPresented: $showNotificationDialog,
                    onConfirm: {
                        openAppSettings()
                    }
                )
                .frame(width: 327, height: 216)
                .padding(.horizontal, 16)
                .zIndex(1)
            }
            
            if showLogoutDialog {
                Color.kBlack.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture { showLogoutDialog = false }
                
                DialogBoxWrapper(
                    state: .childLogout,
                    isPresented: $showLogoutDialog,
                    onConfirm: {
                        onLogoutConfirm()
                    }
                )
                .frame(width: 327, height: 216)
                .padding(.horizontal, 16)
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .onAppear { refreshNotificationStatus() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            refreshNotificationStatus()
        }
    }
}

private extension MySpaceView {
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    isAlarmOn = true
                case .denied:
                    showNotificationDialog = true
                case .notDetermined:
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            isAlarmOn = granted
                            if !granted { showNotificationDialog = true }
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
                isAlarmOn = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
            }
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
