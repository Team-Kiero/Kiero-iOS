//
//  ChildManageView.swift
//  Kiero
//
//  Created by 안치욱 on 5/24/26.
//

import SwiftUI

enum ChildConnectionState {
    case connected
    case waiting
}

struct ChildManageView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var connectionState: ChildConnectionState = .connected
    
    private let childName = "최근영"
    private let inviteCode = "별빛기사단918"
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBarWrapper(type: .back(title: "자녀 관리"), onLeftTap: {
                    dismiss()
                })
                    .frame(height: 32)
                    .padding(.top, 13)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("자녀 연결 관리")
                        .font(Font(UIFont.body3_14_R))
                        .foregroundStyle(.gray400)
                        .padding(.top, 49)
                    
                    childNameCard
                        .padding(.top, 6)
                    
                    connectionStatusView
                        .padding(.top, 6)
                    
                    if connectionState == .waiting {
                        InviteCodeViewWrapper(code: inviteCode, remainingTime: "15:00", isExpired: false)
                            .frame(height: 266)
                            .padding(.top, 11)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer()
                
                if connectionState == .connected {
                    reconnectArea
                        .padding(.horizontal, 16)
                        .padding(.bottom, 34)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

private extension ChildManageView {
    var childNameCard: some View {
        HStack {
            Text(childName)
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.white)
            
            Spacer()
        }
        .frame(height: 45)
        .padding(.horizontal, 13)
        .background(.gray900)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    var connectionStatusView: some View {
        HStack(spacing: 4) {
            Image(.icInfo)
                .resizable()
                .frame(width: 11, height: 11)
                .foregroundStyle(connectionState == .connected ? .gray300 : .main)
            
            Text(connectionState == .connected ? "연결 완료" : "연결 대기")
                .font(Font(UIFont.body5_11_R))
                .foregroundStyle(connectionState == .connected ? .gray300 : .main)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    
    var reconnectArea: some View {
        VStack(spacing: 0) {
            Text("아이가 다시 로그인해야 하는 경우, 연결 코드를 새로 발급해주세요.")
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.gray300)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 27)
            
            CTAButtonWrapper(
                title: "연결 코드 재발급",
                style: .main,
                size: .h49
            ) {
                connectionState = .waiting
            }
        }
    }
}
