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
        if isOngoing || status == "PENDING" {
            return .white
        } else {
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
            
            if isOngoing && status != "COMPLETED" {
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
