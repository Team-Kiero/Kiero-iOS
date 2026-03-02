//
//  DailyJourneyScheduleTimeView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

struct DailyJourneyScheduleTimeView: View {
    let startTime: String
    let endTime: String
    let isOngoing: Bool
    let status: String
    
    private var timeColor: Color {
        if isOngoing{
            return .main
        } else if status == "PENDING" {
            return .gray500
        } else {
            return .gray500.opacity(0.5)
        }
    }
    
    var body: some View {
        (formattedTimeText(startTime) + Text(" ~ ").font(Font(UIFont.body4_12_R)) + formattedTimeText(endTime))
            .foregroundColor(timeColor)
    }
    
    private func formattedTimeText(_ time: String) -> Text {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = formatter.date(from: time) else {
            return Text(time).font(Font(UIFont.body4_12_R))
        }
        
        let periodFormatter = DateFormatter()
        periodFormatter.dateFormat = "a"
        periodFormatter.locale = Locale(identifier: "ko_KR")
        let period = periodFormatter.string(from: date)
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh : mm"
        timeFormatter.locale = Locale(identifier: "ko_KR")
        let timeString = timeFormatter.string(from: date)
        
        return Text(period).font(Font(UIFont.body6_10_R))
        + Text(" \(timeString)").font(Font(UIFont.body4_12_R))
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kBlack
        VStack(spacing: 20) {
            DailyJourneyScheduleTimeView(startTime: "16:00", endTime: "17:00", isOngoing: true, status: "PENDING")
            DailyJourneyScheduleTimeView(startTime: "16:00", endTime: "17:00", isOngoing: false, status: "COMPLETE")
            DailyJourneyScheduleTimeView(startTime: "19:00", endTime: "19:30", isOngoing: false, status: "PENDING")
        }
    }
}
