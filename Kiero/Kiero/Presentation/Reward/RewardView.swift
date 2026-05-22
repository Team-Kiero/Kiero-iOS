//
//  RewardView.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI

struct RewardView: View {
    @ObservedObject var viewModel: RewardViewModel
    
    let onAddRewardTap: () -> Void
    let onEditRewardTap: (Reward) -> Void
    
    @State private var selectedReward: Reward?
    
    let columns = [
        GridItem(.flexible(), spacing: 13),
        GridItem(.flexible(), spacing: 13)
    ]
    
    var body: some View {
        ZStack {
            Color.kBlack.ignoresSafeArea()
            
            if viewModel.rewards.isEmpty {
                EmptyViewWrapper(text: "등록된 보상이 없어요.\n우측 하단 버튼을 눌러 보상을 추가해보세요!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {
                if !viewModel.rewards.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 13) {
                            ForEach(viewModel.rewards) { reward in
                                RewardBox(reward: reward)
                                    .onTapGesture {
                                        showRewardBottomSheet(
                                            reward: reward,
                                            onEdit: {
                                                onEditRewardTap(reward)
                                            },
                                            onDelete: {
                                                viewModel.selectedReward = reward
                                                viewModel.showDeleteDialog = true
                                            }
                                        )
                                    }
                            }
                        }
                        
                        Spacer()
                            .frame(height: 153)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 66)
            
            VStack(spacing: 0) {
                Spacer()
                HStack(spacing: 0) {
                    Spacer()
                    FloatingButtonWrapper(
                        type: .schedule,
                        action: {
                            onAddRewardTap()
                        }
                    )
                    .frame(width: 53, height: 53)
                    .offset(x: -41, y: -124)
                }
            }
            .ignoresSafeArea()
            
            if viewModel.showDeleteDialog, let reward = viewModel.selectedReward {
                Color.kBlack.opacity(0.75)
                    .ignoresSafeArea()
                    .onTapGesture {
                        viewModel.showDeleteDialog = false
                    }
                
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
        .onAppear {
            viewModel.fetchCoupons()
        }
    }
}
