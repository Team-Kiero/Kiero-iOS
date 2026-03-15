//
//  MyPageView.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import SwiftUI

import Kingfisher

struct MyPageView: View {
    @StateObject var viewModel = MyPageViewModel()
    
    @State private var showDialog: Bool = false
    @State private var hasNotification: Bool = false
    
    @State private var isNavigatingToNotification = false
    
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
                        
                        Button(action: {
                            showDialog = true
                        }){
                            HStack {
                                Text("로그아웃")
                                    .font(Font(UIFont.body3_14_R))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Image(.icRight)
                            }
                            .frame(height: 48)
                            .padding(.horizontal, 8)
                        }
                        
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
        }
        .background(.kBlack)
    }
}

struct ConnectionChip: View {
    let count: Int
    
    var body: some View {
        Text(count == 0 ? "연결 필요" : "\(count)명 연결됨")
            .font(Font(UIFont.body6_10_R))
            .foregroundStyle(count == 0 ? .main : .gray500 )
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.gray900)
            .overlay(Capsule().stroke(count == 0 ? .main : .gray500, lineWidth: 1))
    }
}

#Preview {
    MyPageView()
}
