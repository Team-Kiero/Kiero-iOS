//
//  RewardView.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI

struct RewardView: View {
    @ObservedObject var viewModel = RewardViewModel()
    
    @State private var hasNotification: Bool = false
    @State private var isShowingAddView: Bool = false
    @State private var selectedReward: Reward?
    @State private var isNavigatingToNotification = false
    
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
                                            onEdit: { self.selectedReward = reward },
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
                            isShowingAddView = true
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
                    .onTapGesture { viewModel.showDeleteDialog = false }
                
                DialogBoxView(
                    state: .deleteReward(title: reward.title, coin: "\(reward.cost)"),
                    isPresented: $viewModel.showDeleteDialog,
                    onConfirm: {
                        viewModel.deleteReward(reward: reward)
                    }
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear { viewModel.fetchCoupons() }
        .onChange(of: isShowingAddView) { isPresented in
            NotificationCenter.default.post(name: .hideTabBar, object: isPresented)
            NotificationCenter.default.post(name: .hideNavigationBar, object: isPresented)
        }
        .onChange(of: selectedReward != nil) { isPresented in
            NotificationCenter.default.post(name: .hideTabBar, object: isPresented)
            NotificationCenter.default.post(name: .hideNavigationBar, object: isPresented)
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
