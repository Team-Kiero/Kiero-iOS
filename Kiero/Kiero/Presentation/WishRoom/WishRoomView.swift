//
//  WishRoomView.swift
//  Kiero
//
//  Created by 정윤아 on 5/22/26.
//

import SwiftUI

struct WishRoomView: View {
    @ObservedObject var viewModel: WishRoomViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.kBlack.ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationBarWrapper(
                    type: .back(title: "소원의 공간"),
                    onLeftTap: { dismiss() }
                )
                .frame(height: 37)
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        totalCountBanner
                            .padding(.top, 25)
                        
                        todaySection
                            .padding(.top, 24)
                        
                        if !viewModel.previousWishes.isEmpty {
                            previousSection
                                .padding(.top, 24)
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
            
            LinearGradient(
                colors: [.kBlack.opacity(0), .kBlack],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 156)
            .ignoresSafeArea(edges: .bottom)
            .allowsHitTesting(false)
            
            CTAButtonWrapper(
                title: "확인",
                style: .main,
                size: .h49,
                onTap: { dismiss() }
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 19)
            .background(.kBlack)
        }
        .navigationBarHidden(true)
    }
    
    private var totalCountBanner: some View {
        HStack {
            Text("지금까지 \(viewModel.totalWishCount)번의 소원을 빌었어!")
                .font(Font(UIFont.body4_12_R))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray900)
        )
    }
    
    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("오늘 빌었던 소원")
                .font(Font(UIFont.body4_12_R))
                .foregroundColor(.gray200)
            
            if viewModel.hasTodayWishes {
                ForEach(viewModel.todayWishes) { wish in
                    WishRoomBox(type: .wish(wish), isToday: true)
                        .onAppear {
                            if wish.id == viewModel.todayWishes.last?.id {
                                viewModel.loadMoreIfNeeded()
                            }
                        }
                }
            } else {
                WishRoomBox(
                    type: .empty,
                    isToday: true,
                    onEmptyTapped: {
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NotificationCenter.default.post(name: .navigateToWishWell, object: nil)
                        }
                    }
                )
            }
        }
    }
    
    private var previousSection: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("이전 소원")
                .font(Font(UIFont.body4_12_R))
                .foregroundColor(.gray200)
            
            ForEach(viewModel.previousWishes) { wish in
                WishRoomBox(type: .wish(wish), isToday: false)
                    .onAppear {
                        if wish.id == viewModel.previousWishes.last?.id {
                            viewModel.loadMoreIfNeeded()
                        }
                    }
            }
        }
    }
}
