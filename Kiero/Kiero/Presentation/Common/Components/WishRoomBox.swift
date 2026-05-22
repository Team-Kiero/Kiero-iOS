//
//  WishRoomBox.swift
//  Kiero
//
//  Created by 정윤아 on 5/20/26.
//

import SwiftUI

struct WishItem: Identifiable {
    let id: Int
    let title: String
    let acquiredDate: String
    let cost: Int
}

enum WishRoomBoxType {
    case wish(WishItem)
    case empty
}

struct WishRoomBox: View {
    let type: WishRoomBoxType
    let isToday: Bool
    var onEmptyTapped: (() -> Void)? = nil
    
    var body: some View {
        Group {
            switch type {
            case .wish(let wish):
                wishContent(wish)
            case .empty:
                emptyContent()
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray900)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    isToday ? Color.gray300 : Color.clear,
                    lineWidth: 1
                )
        )
    }
    
    // MARK: - Wish Content
    
    @ViewBuilder
    private func wishContent(_ wish: WishItem) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(.icStarRound)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(wish.title)
                    .font(Font(UIFont.title3_16_SB))
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text("획득일")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundStyle(.gray400)
                    Text("|")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundStyle(.gray400)
                    Text(wish.acquiredDate)
                        .font(Font(UIFont.body4_12_R))
                        .foregroundStyle(.gray400)
                }
            }
            
            Spacer()
            
            HStack(spacing: 6) {
                Image(.ic3DCoin)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
                
                Text("\(wish.cost) 사용")
                    .font(Font(UIFont.body6_10_R))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(.gray800))
        }
    }
    
    // MARK: - Empty Content
    
    @ViewBuilder
    private func emptyContent() -> some View {
        VStack(spacing: 17) {
            HStack(alignment: .top, spacing: 10) {
                Image(.icStarRound)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .padding(.top, 4)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("아직 빌었던 소원이 없어!")
                        .font(Font(UIFont.title3_16_SB))
                        .foregroundStyle(.white)
                    
                    Text("오늘의 소원을 빌어볼까?")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundStyle(.gray400)
                }
                
                Spacer()
            }
            
            Button {
                onEmptyTapped?()
            } label: {
                Text("소원 빌러가기")
                    .font(Font(UIFont.title4_14_SB))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray100)
                    )
            }
        }
    }
}
