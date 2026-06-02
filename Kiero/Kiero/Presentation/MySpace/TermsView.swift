//
//  TermsView.swift
//  Kiero
//
//  Created by Hyunseo Han on 5/21/26.
//

import Combine
import SwiftUI

struct TermsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var serviceTermsURL: String?
    @State private var privacyPolicyURL: String?
    @State private var cancellables = Set<AnyCancellable>()
    
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
                        openURL(serviceTermsURL)
                    }
                    MenuListItem(title: "개인정보 처리방침") {
                        openURL(privacyPolicyURL)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear { fetchTerms() }
    }
}

private extension TermsView {
    func fetchTerms() {
        ChildTermsService.shared.fetchTerms()
            .receive(on: DispatchQueue.main)
            .sink { _ in } receiveValue: { dtos in
                for dto in dtos {
                    switch dto.linkType {
                    case "SERVICE_TERMS":
                        serviceTermsURL = dto.link
                    case "PRIVACY_POLICY":
                        privacyPolicyURL = dto.link
                    default:
                        break
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func openURL(_ urlString: String?) {
        guard let urlString, let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
}
