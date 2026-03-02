//
//  DailyJourneyTimelineIndicatorView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

struct DailyJourneyTimelineIndicatorView: View{
    let isOngoing: Bool
    
    private var iconColor: Color {
        isOngoing ? .main : .white
    }
    
    var body: some View {
        VStack (spacing: -2) {
            if isOngoing {
                Image("ic_indicator_rectangle")
                    .renderingMode(.template)
                    .foregroundColor(iconColor)
                    .shadow(color: .main, radius: 4)
                    .shadow(color: .main.opacity(0.5), radius: 8)
            }
            
            Image("ic_indicator_star")
                .renderingMode(.template)
                .foregroundColor(iconColor)
                .shadow(
                    color: isOngoing ? .main : .clear,
                    radius: isOngoing ? 4 : 0
                )
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black
        VStack(spacing: 40) {
            DailyJourneyTimelineIndicatorView(isOngoing: true)
            DailyJourneyTimelineIndicatorView(isOngoing: false)
        }
    }
}
