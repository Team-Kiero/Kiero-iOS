//
//  TermsView.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {

                HStack {
                    Button { dismiss() } label: {
                        Image(.icLeft)
                    }

                    Spacer()

                    Text("키어로 이용 약속")
                        .font(Font(UIFont.head2_20_B))
                        .foregroundStyle(.white)

                    Spacer()

                    Color.clear.frame(width: 24, height: 24)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)

                Text("약관 및 정책")
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(.gray300)
                    .padding(.leading, 16)
                    .padding(.top, 24)

                VStack(spacing: 0) {
                    MenuListItem(title: "서비스 이용약관") {
                        // TODO: 외부 링크로 이동
                    }
                    MenuListItem(title: "개인정보 처리방침") {
                        // TODO: 외부 링크로 이동
                    }
                    MenuListItem(title: "오픈소스 라이선스") {
                        // TODO: 피그마에 '안드만 해당' 이라고 나와있어서 기획한테 문의 넣은 상태
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        TermsView()
    }
}
