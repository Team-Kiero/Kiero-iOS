//
//  TOSView.swift
//  Kiero
//
//  Created by 안치욱 on 5/23/26.
//

import SwiftUI

struct TOSView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text("약관 및 정책")
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.gray400)
                .padding(.leading, 8)
                .padding(.bottom, 11)
            
            VStack(spacing: 0) {
                MenuListItem(title: "서비스 이용약관") {
                    openURL("https://ruddy-adapter-e98.notion.site/KIERO-3608ff4aed3f80ef98b9ffdbe219dc5d")
                }
                MenuListItem(title: "개인정보 처리방침") {
                    openURL("https://ruddy-adapter-e98.notion.site/KIERO-3608ff4aed3f80a08517ca7a45179336")
                }
            }
        }
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
