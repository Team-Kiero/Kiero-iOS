//
//  RequiredTermsBottomSheetView.swift
//  Kiero
//
//  Created by 안치욱 on 5/24/26.
//

import SwiftUI

struct RequiredTermsBottomSheetView: View {
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("아래 약관에 동의 후 서비스 이용이 가능해요.")
                .font(Font(UIFont.head3_16_B))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            
            Divider()
                .frame(height: 1)
                .padding(.top, 8)
                .foregroundColor(.gray800)

            VStack(spacing: 0) {
                TermsAgreementRow(title: "(필수) KIERO 이용약관 동의")

                TermsAgreementRow(title: "(필수) 개인정보 필수 동의")
            }
            .padding(.bottom, 20)

            CTAButtonWrapper(title: "확인", style: .main, size: .h49) {
                onConfirm()
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
        .background(.kBlack)
        .cornerRadius(15, corners: [.topLeft, .topRight])
    }
}

private struct TermsAgreementRow: View {
    let title: String

    var body: some View {
        Button {
            // TODO: 약관 상세 화면 이동
        } label: {
            HStack(spacing: 8) {
                Image(.btnUncheck)
                    .resizable()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)

                Spacer()

                Image(.icRight)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(height: 36)
        }
    }
}

#Preview {
    RequiredTermsBottomSheetView {
        print("확인 버튼 탭")
    }
}
