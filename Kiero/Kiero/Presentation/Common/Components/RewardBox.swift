//
//  RewardBox.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI

struct RewardBox: View {
    let reward: Reward
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("\(reward.title)")
                .font(Font(UIFont.body3_14_R))
                .foregroundStyle(.white)
                .lineLimit(1)
                .truncationMode(.tail)
            
            ChipItemWrapper(
                style: .usedCoinChip,
                icon: .ic3DCoin,
                text: "\(reward.cost) 개"
            )
            .frame(width: 66, height: 24)
        }
        .padding(.vertical, 35)
        .frame(maxWidth: .infinity)
        .background(.gray900)
        .cornerRadius(10)
    }
}
