//
//  ScheduleSectionView.swift
//  Kiero
//
//  Created by 안치욱 on 3/8/26.
//

import SwiftUI

struct ScheduleSectionView: View {
    
    let schedules: [ScheduleItem]
    let isFireLitToday: Bool
    let onTapSchedule: (ScheduleItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if schedules.isEmpty {
                VStack {
                    Spacer()
                    StatusEmptyView(type: .scheduleEmpty)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                    ScheduleBox(
                        schedule: schedule,
                        isFireLitToday: isFireLitToday,
                        showsCurrentScheduleText: shouldShowCurrentScheduleText(at: index),
                        showsNextScheduleText: shouldShowNextScheduleText(at: index),
                        isHighlighted: highlightedIndex == index,
                        isLast: index == schedules.count - 1,
                        onTapSchedule: onTapSchedule
                    )
                    .padding(.horizontal, 29)
                }
                
                if isFireLitToday {
                    ScheduleCompleteFooterView(dotImage: .imgCircleSch1)
                        .padding(.top, 4)
                        .padding(.horizontal, 29)
                }
            }
        }
    }
}

private extension ScheduleSectionView {
    
    var currentIndex: Int? {
        schedules.firstIndex(where: { $0.isNowSchedule })
    }
    
    var highlightedIndex: Int? {
        guard !schedules.isEmpty else { return nil }
        
        if let currentIndex {
            let current = schedules[currentIndex]
            
            switch current.status {
            case .pending, .verified:
                return currentIndex
                
            case .complete, .failed, .skipped:
                let nextIndex = nextUpcomingIndex(after: currentIndex)
                return nextIndex
            }
        }
        
        return firstUpcomingIndex
    }
    
    var nextScheduleTextIndex: Int? {
        guard let currentIndex else { return firstUpcomingIndex }
        return nextUpcomingIndex(after: currentIndex)
    }
    
    var firstUpcomingIndex: Int? {
        let now = currentTimeMinutes
        
        return schedules.firstIndex { schedule in
            startMinutes(of: schedule) > now
        }
    }
    
    func nextUpcomingIndex(after index: Int) -> Int? {
        let now = currentTimeMinutes
        
        guard index + 1 < schedules.count else { return nil }
        
        return schedules[(index + 1)...].firstIndex { schedule in
            startMinutes(of: schedule) > now
        }
    }
    
    var currentTimeMinutes: Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: Date())
        let hour = components.hour ?? 0
        let minute = components.minute ?? 0
        return hour * 60 + minute
    }
    
    func startMinutes(of schedule: ScheduleItem) -> Int {
        let parts = schedule.timeText.split(separator: "-")
        guard let start = parts.first else { return 0 }
        
        let hm = start.split(separator: ":")
        guard hm.count == 2,
              let hour = Int(hm[0]),
              let minute = Int(hm[1]) else { return 0 }
        
        return hour * 60 + minute
    }
    
    func shouldShowCurrentScheduleText(at index: Int) -> Bool {
        guard schedules.indices.contains(index) else { return false }
        
        let schedule = schedules[index]
        
        return schedule.isNowSchedule &&
               (schedule.status == .pending || schedule.status == .verified)
    }
    
    func shouldShowNextScheduleText(at index: Int) -> Bool {
        guard schedules.indices.contains(index) else { return false }
        guard let nextScheduleTextIndex else { return false }
        
        if shouldShowCurrentScheduleText(at: index) {
            return false
        }
        
        return nextScheduleTextIndex == index
    }
}
