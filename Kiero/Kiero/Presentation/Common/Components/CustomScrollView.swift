//
//  CustomScrollView.swift
//  Kiero
//
//  Created by Hyunseo Han on 3/31/26.
//

import SwiftUI

struct CustomScrollView: View {
    let data: DailyJourneyMapData
    let visibleHeight: CGFloat
    var isFireLit: Bool = false
    var isFireNotLit: Bool = false
    
    @State private var scrollOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    private var showBottomGradient: Bool {
        guard contentHeight > visibleHeight, data.schedules.count >= 6 else { return false }
        let maxScroll = contentHeight - visibleHeight
        return -scrollOffset < maxScroll - 1
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ForEach(Array(data.schedules.enumerated()), id: \.element.id) { index, schedule in
                        let isTimeNotStarted: Bool = {
                            guard isFireNotLit, schedule.status == .VERIFIED else { return false }
                            let timeString = String(schedule.startTime.prefix(5))
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            formatter.locale = Locale(identifier: "ko_KR")
                            guard let startDate = formatter.date(from: timeString) else { return false }
                            let now = Date()
                            let calendar = Calendar.current
                            let startComponents = calendar.dateComponents([.hour, .minute], from: startDate)
                            let nowComponents = calendar.dateComponents([.hour, .minute], from: now)
                            let startMinutes = (startComponents.hour ?? 0) * 60 + (startComponents.minute ?? 0)
                            let nowMinutes = (nowComponents.hour ?? 0) * 60 + (nowComponents.minute ?? 0)
                            return nowMinutes < startMinutes
                        }()
                        
                        let effectiveStatus: String = {
                            if isFireLit && schedule.status == .VERIFIED { return "COMPLETED" }
                            if isFireNotLit && schedule.status == .VERIFIED && !isTimeNotStarted { return "COMPLETED" }
                            return schedule.status.rawValue
                        }()
                        let effectiveIsOngoing: Bool = (isFireLit || isFireNotLit) ? false : schedule.isOngoing
                        
                        let hasOngoing = data.schedules.contains { ($0.isOngoing && $0.status != .COMPLETED) || $0.status == .VERIFIED }
                        let isNext: Bool = {
                            guard !isFireLit, !isFireNotLit,
                                  !hasOngoing,
                                  !(schedule.isOngoing && schedule.status != .COMPLETED),
                                  schedule.status == .PENDING else { return false }
                            let isFirstPending = data.schedules.prefix(index).allSatisfy { $0.status != .PENDING || ($0.isOngoing && $0.status != .COMPLETED) }
                            return isFirstPending
                        }()
                        
                        DailyJourneyMapStateRowView(
                            name: schedule.name,
                            startTime: schedule.startTime,
                            endTime: schedule.endTime,
                            isOngoing: effectiveIsOngoing,
                            stoneType: schedule.stoneType.rawValue,
                            status: effectiveStatus,
                            isNext: isNext
                        )
                    }
                }
                .padding(.top, 15)
                .padding(.bottom, 40)
                .background(
                    GeometryReader { geo -> Color in
                        let height = geo.size.height
                        let offset = geo.frame(in: .named("scrollView")).minY
                        
                        DispatchQueue.main.async {
                            self.contentHeight = height
                            self.scrollOffset = offset
                        }
                        return Color.clear
                    }
                )
            }
            .coordinateSpace(name: "scrollView")
            .frame(height: visibleHeight)
            .scrollDisabled(data.schedules.count < 6)
            .mask(
                VStack(spacing: 0) {
                    Rectangle().fill(Color.kBlack)
                    LinearGradient(
                        gradient: Gradient(colors: [Color.kBlack, showBottomGradient ? Color.kBlack.opacity(0) : Color.kBlack]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 54)
                }
            )
            
            if contentHeight > visibleHeight && data.schedules.count >= 6 {
                Capsule()
                    .fill(Color.gray900)
                    .frame(width: 4, height: visibleHeight)
                    .padding(.trailing, 2)
                
                let indicatorHeight: CGFloat = max(30, (visibleHeight / contentHeight) * visibleHeight)
                let maxOffset = contentHeight - visibleHeight
                let currentOffset = min(max(-scrollOffset, 0), maxOffset)
                let indicatorY = maxOffset > 0 ? (currentOffset / maxOffset) * (visibleHeight - indicatorHeight) : 0
                
                Capsule()
                    .fill(Color.white)
                    .frame(width: 4, height: indicatorHeight)
                    .offset(y: indicatorY)
                    .padding(.trailing, 2)
            }
        }
    }
}
