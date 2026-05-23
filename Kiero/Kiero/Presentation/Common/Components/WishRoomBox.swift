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

struct WishRoomBox: View {
    let wish: WishItem
    let isToday: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(.icStarRound)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(wish.title)
                    .font(Font(UIFont.title3_16_SB))
                    .foregroundColor(.white)
                
                HStack(spacing: 4) {
                    Text("획득일")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundColor(.gray400)
                    Text("|")
                        .font(Font(UIFont.body4_12_R))
                        .foregroundColor(.gray400)
                    Text(wish.acquiredDate)
                        .font(Font(UIFont.body4_12_R))
                        .foregroundColor(.gray400)
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
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(.gray800))
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
}
