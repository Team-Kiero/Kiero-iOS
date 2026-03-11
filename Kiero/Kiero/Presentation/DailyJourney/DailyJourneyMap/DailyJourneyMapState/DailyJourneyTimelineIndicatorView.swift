//
//  DailyJourneyTimelineIndicatorView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

struct DailyJourneyTimelineIndicatorView: View {
    let isOngoing: Bool
    let status: String
    let startTime: String
    
    private var isBeforeStart: Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        guard let start = formatter.date(from: startTime),
              let now = formatter.date(from: formatter.string(from: Date())) else {
            return false
        }
        return now < start
    }
    
    private var shouldShowRectangle: Bool {
        isOngoing || status == "PENDING"
    }
    
    private var iconColor: Color {
        if isOngoing || isBeforeStart {
            return .main
        } else if status == "PENDING" {
            return .white
        } else {
            return .white.opacity(0.5)
        }
    }
    
    private var hasGlow: Bool {
        isOngoing || isBeforeStart
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if shouldShowRectangle {
                Image("ic_indicator_rectangle")
                    .renderingMode(.template)
                    .foregroundStyle(iconColor)
                    .frame(height: 0, alignment: .bottom)
                    .offset(y: 2)
            }
            
            Image("ic_indicator_star")
                .renderingMode(.template)
                .foregroundStyle(iconColor)
                .shadow(color: hasGlow ? .main : .clear, radius: hasGlow ? 2 : 0)
        }
    }
}
