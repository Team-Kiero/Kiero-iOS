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
    var body: some View {
        HStack(spacing: 10) {
            Text(name)
                .font(Font(UIFont.head3_16_B))
                .foregroundStyle(isOngoing ? .white : .gray900)
            
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
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 20) {
            DailyJourneyScheduleInfoView(name: "꾸비 성수팝업 가기", isOngoing: true)
            DailyJourneyScheduleInfoView(name: "임상헌 마라탕먹기", isOngoing: false)
        }
    }
}
