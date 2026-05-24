//
//  MyPageView.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import SwiftUI
import UserNotifications

import Kingfisher

struct MyPageView: View {
    @StateObject var viewModel = MyPageViewModel()
    
    @State private var showDialog: Bool = false
    @State private var showNotificationDialog: Bool = false
    @State private var hasNotification: Bool = false
    
    @State private var isNavigatingToNotification = false
    @State private var isAlarmOn: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.kBlack.ignoresSafeArea()
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        HStack(spacing: 9) {
                            if let imageUrl = viewModel.userImage, let url = URL(string: imageUrl){
                                KFImage(url)
                                    .placeholder{ Image(.icParentProfile) }
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 30, height: 30)
                                    .clipShape(Circle())
                            } else { Image(.icParentProfile)}
                            
                            Text("\(viewModel.userName)")
                                .font(Font(UIFont.title3_16_SB))
                                .foregroundStyle(.white)
                            
                            Spacer()
                        }
                        .frame(height: 60)
                        .padding(.horizontal, 5)
                        .padding(.top, 74)
                        
                        
                        Rectangle()
                            .fill(.gray900)
                            .frame(height: 1)
                            .padding(.bottom, 11)
                        
                        Button(action: {
                            print("자녀 연결 관리")
                        }){
                            HStack(spacing: 0) {
                                Text("자녀 연결 관리")
                                    .font(Font(UIFont.body3_14_R))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                ConnectionChip(count: viewModel.connectedChild)
                                
                                Image(.icRight)
                            }
                            .frame(height: 48)
                            .padding(.horizontal, 8)
                        }
                        
                        HStack(spacing: 0) {
                            Text("푸시 알림")
                                .font(Font(UIFont.body3_14_R))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            CustomToggle(isOn: Binding(
                                get: { isAlarmOn },
                                set: { newValue in
                                    if newValue {
                                        checkNotificationPermission()
                                    } else {
                                        isAlarmOn = false
                                    }
                                }
                            ))
                        }
                        .frame(height: 48)
                        .padding(.horizontal, 8)
                        
                        MenuListItem(title: "고객지원") {
                            openURL("https://docs.google.com/forms/d/e/1FAIpQLSc2NRxLO6z5DvcdADtapt2Tsaa76MNxhgEMkYORYGiUihgZpw/viewform")
                        }
                        .frame(height: 48)
                        
                        TOSView()
                            .padding(.top, 24)
                        
                        Text("앱 버전 v\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")")
                            .font(Font(UIFont.body4_12_R))
                            .foregroundStyle(.gray400)
                            .padding(.top, 24)
                            .padding(.leading, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Button {
                            showDialog = true
                        } label: {
                            Text("로그아웃")
                                .font(Font(UIFont.body4_12_R))
                                .foregroundStyle(.gray400)
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 11)
                        .padding(.leading, 8)
                        
                        Button {
                            print("회원 탈퇴")
                        } label: {
                            Text("회원 탈퇴")
                                .font(Font(UIFont.body4_12_R))
                                .foregroundStyle(.gray400)
                                .underline()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.top, 11)
                        .padding(.leading, 8)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                }
                .navigationDestination(isPresented: $isNavigatingToNotification) {
                    NotificationFeedWrapper()
                        .toolbar(.hidden, for: .navigationBar)
                        .ignoresSafeArea()
                        .onAppear {
                            NotificationCenter.default.post(name: .hideTabBar, object: true)
                        }
                        .onDisappear {
                            NotificationCenter.default.post(name: .hideTabBar, object: false)
                        }
                }
                
                if showNotificationDialog {
                    Color.kBlack.opacity(0.75)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showNotificationDialog = false
                        }
                    
                    DialogBoxWrapper(
                        state: .parentNotification,
                        isPresented: $showNotificationDialog,
                        onConfirm: {
                            openAppSettings()
                        }
                    )
                    .frame(width: 327, height: 216)
                    .padding(.horizontal, 16)
                    .zIndex(1)
                }
                
                if showDialog {
                    Color.kBlack.opacity(0.75)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showDialog.toggle()
                        }
                    
                    DialogBoxWrapper(
                        state: .logout,
                        isPresented: $showDialog,
                        onConfirm: {
                            viewModel.requestLogout()
                        }
                    )
                    .frame(width: 327, height: 216)
                    .padding(.horizontal, 16)
                    .zIndex(1)
                }
            }
            .onAppear {
                refreshNotificationStatus()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                refreshNotificationStatus()
            }
        }
        .background(.kBlack)
    }
}

// MARK: - Actions

private extension MyPageView {
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .authorized, .provisional, .ephemeral:
                    isAlarmOn = true
                    
                case .denied:
                    isAlarmOn = false
                    showNotificationDialog = true
                    
                case .notDetermined:
                    UNUserNotificationCenter.current()
                        .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                            DispatchQueue.main.async {
                                isAlarmOn = granted
                                
                                if !granted {
                                    showNotificationDialog = true
                                }
                            }
                        }
                    
                @unknown default:
                    isAlarmOn = false
                    showNotificationDialog = true
                }
            }
        }
    }
    
    func refreshNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isAlarmOn = settings.authorizationStatus == .authorized
                || settings.authorizationStatus == .provisional
                || settings.authorizationStatus == .ephemeral
            }
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}

struct ConnectionChip: View {
    let count: Int
    
    var body: some View {
        // API 연결 때 수정
        Text(count == 0 ? "연결 필요" : "\(count)명 연결됨")
            .font(Font(UIFont.body6_10_R))
            .foregroundStyle(count == 0 ? .main : .gray500 )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.gray900, in: Capsule())
            .overlay(Capsule().stroke(count == 0 ? .main : .gray500, lineWidth: 1))
    }
}

#Preview {
    MyPageView()
}
