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
                        isAfterTenPM: isAfterTenPM,
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
    var isAfterTenPM: Bool {
        Calendar.current.component(.hour, from: Date()) >= 22
    }

    var currentIndex: Int? {
        schedules.firstIndex(where: { $0.isNowSchedule })
    }
    
    var highlightedIndex: Int? {
        guard !schedules.isEmpty else { return nil }
        guard !isAfterTenPM else { return nil }
        
        if let currentIndex {
            let current = schedules[currentIndex]
            
            switch current.status {
            case .pending, .verified:
                return currentIndex
                
            case .complete, .failed, .skipped:
                let nextIndex = currentIndex + 1
                return nextIndex < schedules.count ? nextIndex : nil
            }
        }
        
        return schedules.isEmpty ? nil : 0
    }
    
    var nextScheduleTextIndex: Int? {
        guard !schedules.isEmpty else { return nil }
        guard !isAfterTenPM else { return nil }
        
        if let currentIndex {
            let nextIndex = currentIndex + 1
            return nextIndex < schedules.count ? nextIndex : nil
        }
        
        return 0
    }
    
    func shouldShowCurrentScheduleText(at index: Int) -> Bool {
        guard !isAfterTenPM else { return false }
        guard schedules.indices.contains(index) else { return false }
        
        let schedule = schedules[index]
        guard schedule.isNowSchedule else { return false }
        
        switch schedule.status {
        case .pending, .verified:
            return true
        case .complete, .failed, .skipped:
            return false
        }
    }
    
    func shouldShowNextScheduleText(at index: Int) -> Bool {
        guard !isAfterTenPM else { return false }
        guard let nextScheduleTextIndex else { return false }
        guard schedules.indices.contains(index) else { return false }
        
        if shouldShowCurrentScheduleText(at: index) {
            return false
        }
        
        return nextScheduleTextIndex == index
    }
}
