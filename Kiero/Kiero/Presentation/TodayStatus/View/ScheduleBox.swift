//
//  ScheduleBox.swift
//  Kiero
//
//  Created by 안치욱 on 3/6/26.
//

import SwiftUI

enum TodayStatus: String, Decodable {
    case complete = "COMPLETED"
    case failed = "FAILED"
    case skipped = "SKIPPED"
    case verified = "VERIFIED"
    case pending = "PENDING"
}

struct ScheduleBox: View {
    let schedule: ScheduleItem
    let isFireLitToday: Bool
    let showsCurrentScheduleText: Bool
    let showsNextScheduleText: Bool
    let isHighlighted: Bool
    let isLast: Bool
    let isAfterTenPM: Bool
    let onTapSchedule: (ScheduleItem) -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            TimelineColumnView(
                dotImage: dotImage,
                dotGlowColor: dotGlowColor,
                lineGradient: lineGradient,
                lineHeight: 94
            )
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 0) {
                if isHighlighted {
                    if showsCurrentScheduleText {
                        Text("현재 일정")
                            .font(Font(UIFont.body6_10_R))
                            .foregroundStyle(.gray400)
                    }
                    
                    if showsNextScheduleText {
                        Text("다음 일정")
                            .font(Font(UIFont.body6_10_R))
                            .foregroundStyle(.gray400)
                    }
                }
                
                Text(schedule.timeText)
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(timeColor)
                    .padding(.bottom, 8)
                
                ScheduleCard(
                    schedule: schedule,
                    isHighlighted: isHighlighted,
                    onTap: {
                        onTapSchedule(schedule)
                    }
                )
            }
            
            Spacer(minLength: 0)
        }
    }
}

private extension ScheduleBox {
    var timeColor: Color {
        if isAfterTenPM {
            return .gray400
        }
        
        if isHighlighted {
            return .main
        } else {
            switch schedule.status {
            case .complete, .failed, .skipped, .verified:
                return .gray400
            case .pending:
                return .gray800
            }
        }
    }
    
    var dotImage: ImageResource {
        if isFireLitToday {
            return .imgCircleSch1
        }
        else if schedule.isNowSchedule {
            return .imgCircleMain
        }
        else {
            switch schedule.status {
            case .pending:
                return .imgCircleGray
            default:
                return .imgCircleSch1
            }
        }
    }
    
    var dotGlowColor: Color {
        if isFireLitToday {
            return .schedule1
        } else if schedule.isNowSchedule {
            return .main
        } else {
            switch schedule.status {
            case .verified:
                return .main
            case .pending:
                return .gray800
            default:
                return .schedule1
            }
        }
    }
    
    var lineGradient: LinearGradient {
        if isFireLitToday {
            return LinearGradient(
                colors: [.gray400, .gray600],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        else {
            if isLast {
                return LinearGradient(
                    colors: [.clear, .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            else if schedule.isNowSchedule {
                return LinearGradient(
                    colors: [.gray400, .gray600],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            else {
                switch schedule.status {
                case .complete, .failed, .skipped:
                    return LinearGradient(
                        colors: [.gray400, .gray600],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                case .verified:
                    return LinearGradient(
                        colors: [.gray400, .gray800],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                case .pending:
                    return LinearGradient(
                        colors: [.gray800, .kBlack],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
        }
    }
}
