//
//  MyPageView.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import SwiftUI

struct MyPageView: View {
    
    @StateObject private var viewModel = MyPageViewModel()
    
    @State private var showDialog: Bool = false
<<<<<<< HEAD
    @State private var hasNotification: Bool = false
=======
>>>>>>> origin/feat/#194-myPage
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            VStack {
<<<<<<< HEAD
                NavigationBarWrapper(
                    type: .main(title: "마이페이지"),
                    isNotificationActive: hasNotification,
                    onRightTap: {
                        //TODO: - 알림 피드와 연결
                        print("알림피드로 이동")
                    }
                )
                .frame(height: 45)
                .padding(.bottom, 16)
                .padding(.top, 13)
                .padding(.horizontal, -16)
=======
                //TODO: - 네비게이션 바 연결
>>>>>>> origin/feat/#194-myPage
                
                HStack(spacing: 9) {
                    
                    //TODO: - 프로필 이미지 넣기
                    Image(.icParentProfile)
                    
                    Text("\(viewModel.userName)")
                        .font(Font(UIFont.title3_16_SB))
                        .foregroundColor(.white)
                    
                    Spacer()
                }
                .padding(.horizontal, 5)
                
                Rectangle()
                    .fill(.gray900)
                    .frame(height: 1)
                    .padding(.bottom, 11)
                
                
                Button(action: {
                    print("자녀 연결 관리")
                }){
                    HStack {
                        Text("자녀 연결 관리")
                            .font(Font(UIFont.body3_14_R))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        ConnectionChip(count: viewModel.connectedChild)
                        
                        Image(.icRight)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                }
                
                Button(action: {
                    showDialog = true
                }){
                    HStack {
                        Text("로그아웃")
                            .font(Font(UIFont.body3_14_R))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Image(.icRight)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                }
                
                Spacer()
                
                //TODO: - 탭바 연결
            }
            .padding(.horizontal, 16)
            
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
                        print("로그아웃 API 호출")
                    }
                )
                .frame(width: UIScreen.main.bounds.width - 32, height: 197)
                .zIndex(1)
            }
        }
    }
}

struct ConnectionChip: View {
    let count: Int
    
    var body: some View {
        Text(count == 0 ? "연결 필요" : "\(count)명 연결됨")
            .font(Font(UIFont.body6_10_R))
            .foregroundColor(.gray500)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.gray900)
            .overlay(Capsule().stroke(.gray500, lineWidth: 1))
    }
}

#Preview {
    MyPageView()
}
