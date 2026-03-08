//
//  ScheduleSectionView.swift
//  Kiero
//
//  Created by 안치욱 on 3/8/26.
//

import SwiftUI

struct ScheduleSectionView: View {
    let schedules: [TodayScheduleDTO]
    let isFireLitToday: Bool
    let onTapSchedule: (TodayScheduleDTO) -> Void

    var body: some View {
        VStack(spacing: 0) {
            if schedules.isEmpty {
                Spacer()
                
                StatusEmptyView(type: .scheduleEmpty)
                
                Spacer()
            } else {
                ForEach(Array(schedules.enumerated()), id: \.element.id) { index, schedule in
                    ScheduleBox(
                        schedule: schedule,
                        isFireLitToday: isFireLitToday,
                        showsNextScheduleText: shouldShowNextScheduleText(at: index),
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
    func shouldShowLine(at index: Int) -> Bool {
        if isFireLitToday {
            return true
        } else {
            return index != schedules.count - 1
        }
    }

    func shouldShowNextScheduleText(at index: Int) -> Bool {
        guard index > 0 else { return false }
        return schedules[index - 1].isNowSchedule
    }
}
