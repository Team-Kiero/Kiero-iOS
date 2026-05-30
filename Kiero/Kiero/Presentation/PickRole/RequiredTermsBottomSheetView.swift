//
//  RequiredTermsBottomSheetView.swift
//  Kiero
//
//  Created by 안치욱 on 5/24/26.
//

import SwiftUI

struct RequiredTermsBottomSheetView: View {
    let onTermsTap: () -> Void
    let onPrivacyTap: () -> Void
    let onConfirm: () -> Void

    @State private var isTermsChecked = false
    @State private var isPrivacyChecked = false

    private var isAllChecked: Bool {
        isTermsChecked && isPrivacyChecked
    }

    var body: some View {
        VStack(spacing: 0) {
            Text("아래 약관에 동의 후 서비스 이용이 가능해요.")
                .font(Font(UIFont.head3_16_B))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)

            Divider()
                .frame(height: 1)
                .overlay(Color.gray800)
                .padding(.top, 8)

            VStack(spacing: 0) {
                TermsAgreementRow(
                    title: "(필수) KIERO 이용약관 동의",
                    isChecked: $isTermsChecked,
                    onDetailTap: onTermsTap
                )

                TermsAgreementRow(
                    title: "(필수) 개인정보 필수 동의",
                    isChecked: $isPrivacyChecked,
                    onDetailTap: onPrivacyTap
                )
            }
            .padding(.vertical, 16)

            CTAButtonWrapper(
                title: "확인",
                style: .main,
                size: .h49,
                enabledStyle: .main,
                disabledStyle: .gray800,
                isEnabled: isAllChecked
            ) {
                guard isAllChecked else { return }
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
    @Binding var isChecked: Bool
    let onDetailTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {

            Button {
                isChecked.toggle()
            } label: {
                HStack(spacing: 8) {
                    Image(isChecked ? .btnCheckFill : .btnUncheck)
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text(title)
                        .font(Font(UIFont.body3_14_R))
                        .foregroundColor(.white)
                        .offset(y: -2)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                onDetailTap()
            } label: {
                Image(.icRight)
                    .resizable()
                    .frame(width: 24, height: 24)
            }
            .buttonStyle(.plain)
        }
        .frame(height: 44)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        Color.black
            .ignoresSafeArea()

        RequiredTermsBottomSheetView(
            onTermsTap: {
                print("이용약관")
            },
            onPrivacyTap: {
                print("개인정보")
            },
            onConfirm: {
                print("확인")
            }
        )
    }
}
