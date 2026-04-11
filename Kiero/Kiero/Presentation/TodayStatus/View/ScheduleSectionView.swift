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
    var nowMinutes: Int {
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
    
    func endMinutes(of schedule: ScheduleItem) -> Int {
        let parts = schedule.timeText.split(separator: "-")
        guard parts.count == 2 else { return 0 }
        
        let end = parts[1]
        let hm = end.split(separator: ":")
        guard hm.count == 2,
              let hour = Int(hm[0]),
              let minute = Int(hm[1]) else { return 0 }
        
        return hour * 60 + minute
    }
    
    var actualCurrentIndex: Int? {
        schedules.firstIndex { schedule in
            let start = startMinutes(of: schedule)
            let end = endMinutes(of: schedule)
            return start <= nowMinutes && nowMinutes < end
        }
    }
    
    var initialHighlightedIndex: Int? {
        if let actualCurrentIndex {
            return actualCurrentIndex
        }
        
        return schedules.firstIndex { schedule in
            startMinutes(of: schedule) > nowMinutes
        }
    }
    
    func nextIndex(after index: Int) -> Int? {
        let next = index + 1
        return schedules.indices.contains(next) ? next : nil
    }
    
    var highlightedIndex: Int? {
        guard let startIndex = initialHighlightedIndex else { return nil }
        
        var currentIndex: Int? = startIndex
        
        while let index = currentIndex {
            switch schedules[index].status {
            case .pending, .verified:
                return index
                
            case .complete, .skipped:
                currentIndex = nextIndex(after: index)
                
            case .failed:
                return nil
            }
        }
        
        return nil
    }
    
    func shouldShowCurrentScheduleText(at index: Int) -> Bool {
        guard let actualCurrentIndex else { return false }
        guard let highlightedIndex else { return false }
        
        return index == actualCurrentIndex && index == highlightedIndex
    }
    
    func shouldShowNextScheduleText(at index: Int) -> Bool {
        guard let highlightedIndex else { return false }
        return index == highlightedIndex && !shouldShowCurrentScheduleText(at: index)
    }
}
