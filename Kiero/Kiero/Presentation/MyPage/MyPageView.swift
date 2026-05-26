//
//  MyPageView.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import SwiftUI

import Kingfisher

struct MyPageView: View {
    @StateObject var viewModel: MyPageViewModel
    
    @State private var showDialog: Bool = false
    
    let onChildManageTap: (() -> Void)?
    let onDeleteAccountTap: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    
                    HStack(spacing: 9) {
                        if let imageUrl = viewModel.userImage,
                           let url = URL(string: imageUrl) {
                            KFImage(url)
                                .placeholder { Image(.icParentProfile) }
                                .resizable()
                                .scaledToFill()
                                .frame(width: 30, height: 30)
                                .clipShape(Circle())
                        } else {
                            Image(.icParentProfile)
                        }
                        
                        Text(viewModel.userName)
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
                        onChildManageTap?()
                    }) {
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
                            get: { viewModel.isAlarmOn },
                            set: { newValue in
                                if newValue {
                                    viewModel.checkNotificationPermission()
                                } else {
                                    viewModel.isAlarmOn = false
                                }
                            }
                        ))
                    }
                    .frame(height: 48)
                    .padding(.horizontal, 8)
                    
                    MenuListItem(title: "고객지원") {
                        viewModel.openURL(
                            "https://docs.google.com/forms/d/e/1FAIpQLSc2NRxLO6z5DvcdADtapt2Tsaa76MNxhgEMkYORYGiUihgZpw/viewform"
                        )
                    }
                    .frame(height: 48)
                    
                    TermsAndConditionsView()
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
                        onDeleteAccountTap?()
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
            
            if viewModel.showNotificationDialog {
                Color.kBlack.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.showNotificationDialog = false
                    }
                
                DialogBoxWrapper(
                    state: .parentNotification,
                    isPresented: $viewModel.showNotificationDialog,
                    onConfirm: {
                        viewModel.openAppSettings()
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
        .background(.kBlack)
        .onAppear {
            viewModel.refreshNotificationStatus()
        }
        .onReceive(
            NotificationCenter.default.publisher(
                for: UIApplication.willEnterForegroundNotification
            )
        ) { _ in
            viewModel.refreshNotificationStatus()
        }
    }
}

struct ConnectionChip: View {
    let count: Int
    
    // TODO: - API 연결 시 수정
    var body: some View {
        Text(count == 0 ? "연결 필요" : "\(count)명 연결됨")
            .font(Font(UIFont.body6_10_R))
            .foregroundStyle(count == 0 ? .main : .gray500)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.gray900, in: Capsule())
            .overlay(Capsule().stroke(count == 0 ? .main : .gray500, lineWidth: 1))
    }
}
