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
    let isNext: Bool
    
    private var isEnded: Bool {
        status == "COMPLETED" || status == "FAILED" || status == "SKIPPED"
    }
    
    private var shouldShowRectangle: Bool {
        !isEnded
    }
    
    private var iconColor: Color {
        if isEnded {
            return .white.opacity(0.5)
        }
        if isOngoing || isNext {
            return .main
        }
        return .white
    }
    
    private var hasGlow: Bool {
        !isEnded && (isOngoing || isNext)
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
