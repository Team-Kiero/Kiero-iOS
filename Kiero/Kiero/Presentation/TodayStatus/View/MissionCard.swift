//
//  MissionCard.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI

struct MissionCard: View {
    let mission: MissionDTO
    
    var body: some View {
        HStack {
            Text(mission.name)
                .font(Font(UIFont.title3_16_SB))
                .foregroundStyle(.white)
            
            Spacer()
            
            rewardBadge
        }
        .frame(height: 57)
    }
}

private extension MissionCard {
    var rewardBadge: some View {
        HStack(spacing: 4) {
            Image(.ic3DCoin)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)

            Text("\(mission.reward)개")
                .font(Font(UIFont.body6_10_R))
                .foregroundStyle(.gray500)
                .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, 8)
        .frame(height: 24)
        .background(
            Capsule()
                .stroke(Color.gray500, lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.gray900
        MissionCard(mission: MissionDTO(name: "설거지하기", reward: 50))
    }
}
