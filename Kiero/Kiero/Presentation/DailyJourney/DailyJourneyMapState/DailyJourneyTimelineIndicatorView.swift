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
    
    private var shouldShowRectangle: Bool {
        isOngoing || status == "PENDING"
    }
    
    private var iconColor: Color {
        if isOngoing {
            return .main
        } else if status == "PENDING" {
            return .white
        } else {
            return .white.opacity(0.5)
        }
    }
    
    private var hasGlow: Bool {
        isOngoing
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if shouldShowRectangle {
                Image("ic_indicator_rectangle")
                    .renderingMode(.template)
                    .foregroundColor(iconColor)
                    .frame(height: 0, alignment: .bottom)
                    .offset(y: 2)
            }
            
            Image("ic_indicator_star")
                .renderingMode(.template)
                .foregroundColor(iconColor)
                .shadow(color: hasGlow ? .main : .clear, radius: hasGlow ? 2 : 0)
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kBlack
        
        VStack(spacing: 40) {
            DailyJourneyTimelineIndicatorView(isOngoing: true, status: "PENDING")
            DailyJourneyTimelineIndicatorView(isOngoing: false, status: "PENDING")
            DailyJourneyTimelineIndicatorView(isOngoing: false, status: "COMPLETE")
        }
    }
}
