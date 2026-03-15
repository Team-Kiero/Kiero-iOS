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
        GeometryReader { proxy in
            let topOffset: CGFloat = 102
            
            ZStack(alignment: .bottomTrailing) {
                Color.kBlack.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.rewards.isEmpty {
                        Spacer()
                            .frame(height: topOffset)
                        
                        EmptyViewWrapper(text: "등록된 보상이 없어요.\n우측 하단 버튼을 눌러 보상을 추가해보세요!")
                        
                        Spacer()
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
                            .padding(.horizontal, 16)
                            .padding(.top, topOffset)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                FloatingButtonWrapper(
                    type: .schedule,
                    action: { isShowingAddView = true }
                )
                .frame(width: 53, height: 53)
                .padding(.trailing, 32)
                .padding(.bottom, 115)
                
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
        }
        .onAppear { viewModel.fetchCoupons() }
    }
}

//import SwiftUI
//
//struct RewardView: View {
//    @ObservedObject var viewModel = RewardViewModel()
//    
//    @State private var hasNotification: Bool = false
//    @State private var isShowingAddView: Bool = false
//    @State private var selectedReward: Reward?
//    @State private var isNavigatingToNotification = false
//    
//    let columns = [
//        GridItem(.flexible(), spacing: 13),
//        GridItem(.flexible(), spacing: 13)
//    ]
//    
//    var body: some View {
//        ZStack(alignment: .bottomTrailing) {
//            Color.kBlack.ignoresSafeArea()
//            
//            VStack(spacing: 0) {
//                if viewModel.rewards.isEmpty {
//                    Spacer()
//                    
//                    EmptyViewWrapper(text: "등록된 보상이 없어요.\n우측 하단 버튼을 눌러 보상을 추가해보세요!")
//                    
//                    Spacer()
//                } else {
//                    ScrollView {
//                        LazyVGrid(columns: columns, spacing: 13) {
//                            ForEach(viewModel.rewards) { reward in
//                                RewardBox(reward: reward)
//                                    .onTapGesture {
//                                        showRewardBottomSheet(
//                                            reward: reward,
//                                            onEdit: { self.selectedReward = reward },
//                                            onDelete: {
//                                                viewModel.selectedReward = reward
//                                                viewModel.showDeleteDialog = true
//                                            }
//                                        )
//                                    }
//                            }
//                        }
//                        .padding(.horizontal, 16)
//                        .padding(.top, 102)
//                    }
//                }
//            }
//            
//            FloatingButtonWrapper(
//                type: .schedule,
//                action: {
//                    isShowingAddView = true
//                }
//            )
//            .frame(width: 53, height: 53)
//            .padding(.trailing, 32)
//            .padding(.bottom, 115)
//            
//            if viewModel.showDeleteDialog, let reward = viewModel.selectedReward {
//                Color.kBlack.opacity(0.75)
//                    .ignoresSafeArea()
//                    .onTapGesture { viewModel.showDeleteDialog = false }
//                
//                DialogBoxWrapper(
//                    state: .deleteReward(title: reward.title, coin: "\(reward.cost)"),
//                    isPresented: $viewModel.showDeleteDialog,
//                    onConfirm: {
//                        viewModel.deleteReward(reward: reward)
//                    }
//                )
//                .frame(width: 327, height: 216)
//                .transition(.scale.combined(with: .opacity))
//            }
//        }
//        .background(.kBlack)
//        .onAppear { viewModel.fetchCoupons() }
//    }
//}
