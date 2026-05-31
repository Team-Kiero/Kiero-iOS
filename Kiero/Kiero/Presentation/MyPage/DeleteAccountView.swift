//
//  DeleteAccountView.swift
//  Kiero
//
//  Created by 안치욱 on 5/24/26.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel = DeleteAccountViewModel()
    @State private var isChecked = false
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBarWrapper(type: .back(title: "회원 탈퇴"), onLeftTap: {
                    dismiss()
                })
                    .frame(height: 32)
                    .padding(.top, 13)
                
                contentBox
                    .padding(.top, 32)
                
                Spacer()
                
                agreementView
                    .padding(.bottom, 24)
                
                CTAButtonWrapper(title: "계정 삭제하고 탈퇴하기", style: .main, size: .h49, enabledStyle: .main, disabledStyle: .gray900, isEnabled: isChecked) {
                    viewModel.deleteAccount()
                }
                .padding(.bottom, 17)
            }
            .padding(.horizontal, 16)
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.route) { route in
            switch route {
            case .pickRole:
                LogoutHelper.logoutToPickRole()
                
            case .toast(let message):
                Toast.show(message: message, bottomInset: 83)
            }
        }
    }
}

private extension DeleteAccountView {
    var contentBox: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("""
            보호자 계정이 탈퇴되면 연결된 자녀 계정에서도 서비스를 이용할 수 없습니다.
            
            삭제되는 정보
            • 보호자 계정 정보
            • 연결된 자녀 프로필 정보
            • 자녀 일정 및 미션
            • 금화/보상 정보
            • 알림 설정 정보
            • 서비스 이용 기록
            
            탈퇴 후에는 삭제된 데이터를 복구할 수 없습니다.
            같은 계정으로 다시 가입해도 기존 기록은 이어지지 않습니다.
            """)
            .font(Font(UIFont.body4_12_R))
            .foregroundStyle(.gray200)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.gray900)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    var agreementView: some View {
        Button {
            isChecked.toggle()
        } label: {
            HStack(spacing: 8) {
                Image(isChecked ? .btnCheckFill : .btnUncheck)
                    .resizable()
                    .frame(width: 24, height: 24)
                
                Text("위 내용을 모두 확인했으며, 탈퇴 후 데이터가 복구되지 않는다는 점에 동의합니다.")
                    .font(Font(UIFont.body3_14_R))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
        }
    }
}
