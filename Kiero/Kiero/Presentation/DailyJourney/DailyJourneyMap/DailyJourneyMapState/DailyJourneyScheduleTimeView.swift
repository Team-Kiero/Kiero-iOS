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
    let isNext: Bool
    
    private var isEnded: Bool {
        status == "COMPLETED" || status == "FAILED" || status == "SKIPPED"
    }

    private var timeColor: Color {
        if isEnded {
            return .gray500.opacity(0.5)
        }
        if isOngoing || isNext {
            return .main
        }
        return .gray500
    }
    
    var body: some View {
        (formattedTimeText(startTime) + Text(" ~ ").font(Font(UIFont.body4_12_R)) + formattedTimeText(endTime))
            .foregroundStyle(timeColor)
    }
    
    private func formattedTimeText(_ time: String) -> Text {
        let displayTime = String(time.prefix(5))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        
        guard let date = formatter.date(from: displayTime) else {
            return Text(displayTime).font(Font(UIFont.body4_12_R))
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
        + Text("  \(timeString)").font(Font(UIFont.body4_12_R))
    }
}
