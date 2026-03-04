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
    @State private var isShowingAddView: Bool = false
    @State private var selectedReward: Reward?
    
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
                                    .onTapGesture {
                                        showRewardBottomSheet(
                                            reward: reward,
                                            onEdit: { self.selectedReward = reward },
                                            onDelete: {
                                                viewModel.selectedReward = reward
                                                viewModel.showDeleteDialog = true
                                            }
                                        )
                                    }
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
                    isShowingAddView = true
                }
            )
            .frame(width: 53, height: 53)
            .padding(.top, 596)
            .padding(.leading, 291)
            
            if viewModel.showDeleteDialog, let reward = viewModel.selectedReward {
                Color.kBlack.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.showDeleteDialog = false }
                
                DialogBoxWrapper(
                    state: .deleteReward(title: reward.title, coin: "\(reward.cost)"),
                    isPresented: $viewModel.showDeleteDialog,
                    onConfirm: {
                        viewModel.deleteReward(reward: reward)
                    }
                )
                .frame(width: 327, height: 216)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .fullScreenCover(isPresented: $isShowingAddView) {
            RewardEditView(mode: .add) { title, cost in
                viewModel.addReward(title: title, cost: cost)
            }
        }
        .fullScreenCover(item: $selectedReward) { reward in
            RewardEditView(mode: .edit(reward)) { title, cost in
                viewModel.updateReward(id: reward.id, title: title, cost: cost)
            }
        }
    }
}

#Preview {
    RewardView()
}
