//
//  RewardView.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI

struct RewardView: View {
    @StateObject private var viewModel = RewardViewModel()
    @State private var hasNotification: Bool = false
    
    let columns = [
        GridItem(.flexible(), spacing: 13),
        GridItem(.flexible(), spacing: 13)
    ]
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            VStack {
                NavigationBarWrapper(
                    type: .main(title: "보상"),
                    isNotificationActive: hasNotification,
                    onRightTap: { print ("알림 탭 클릭")}
                )
                .frame(height: 45)
                
                if viewModel.rewards.isEmpty {
                    EmptyViewWrapper(text: "등록된 보상이 없어요.\n우측 하단 버튼을 눌러 보상을 추가해보세요!")
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 13) {
                            ForEach(viewModel.rewards) { reward in
                                RewardBox(reward: reward)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            
            FloatingButtonWrapper(
                type: .schedule,
                action: {
                    print("보상 추가 버튼 클릭")
                }
            )
            .frame(width: 53, height: 53)
            .padding(.top, 596)
            .padding(.leading, 291)
        }
    }
}

#Preview {
    RewardView()
}
