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
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                TermsAgreementRow(title: "(필수) KIERO 이용약관 동의")

                TermsAgreementRow(title: "(필수) 개인정보 필수 동의")
            }
            .padding(.bottom, 20)

            Button {
                onConfirm()
            } label: {
                Text("확인")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.06, green: 0.86, blue: 0.78))
                    .cornerRadius(4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .padding(.bottom, 34)
        .background(Color(red: 0.13, green: 0.14, blue: 0.16))
        .cornerRadius(8, corners: [.topLeft, .topRight])
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

                Image(.btnUncheck)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .frame(height: 36)
        }
    }
}
