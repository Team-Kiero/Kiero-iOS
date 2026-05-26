//
//  TermsAndConditionsView.swift
//  Kiero
//
//  Created by 안치욱 on 5/23/26.
//

import SwiftUI

struct TermsAndConditionsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("약관 및 정책")
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.gray400)
                .padding(.leading, 8)
                .padding(.bottom, 11)
            
            VStack(spacing: 0) {
                MenuListItem(title: "서비스 이용약관") {
                    // TODO: - API 연결
                }
                MenuListItem(title: "개인정보 처리방침") {
                    // TODO: - API 연결
                }
            }
        }
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
