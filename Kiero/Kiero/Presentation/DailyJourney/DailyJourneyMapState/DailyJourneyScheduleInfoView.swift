//
//  DailyJourneyScheduleInfoView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

struct DailyJourneyScheduleInfoView: View {
    let name: String
    let isOngoing: Bool
    let status: String
    
    private var nameColor: Color {
        switch (isOngoing, status) {
        case (true, _),
            (_, "PENDING"):
            return .white
        default:
            return .white.opacity(0.5)
        }
    }
    
    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(Font(UIFont.head3_16_B))
                .foregroundStyle(nameColor)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(1)
            
            if isOngoing {
                Text("진행중")
                    .font(Font(UIFont.body6_10_R))
                    .foregroundStyle(.main)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray900)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.main, lineWidth: 1)
                    )
                    .fixedSize()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kBlack
        
        VStack(spacing: 20) {
            DailyJourneyScheduleInfoView(
                name: "수학 학원 가기",
                isOngoing: true,
                status: "ONGOING"
            )
            
            DailyJourneyScheduleInfoView(
                name: "영어 숙제 하기",
                isOngoing: false,
                status: "PENDING"
            )
            
            DailyJourneyScheduleInfoView(
                name: "미술 숙제 제출하기",
                isOngoing: false,
                status: "COMPLETED"
            )
        }
        .padding()
    }
}
