//
//  ScheduleBox.swift
//  Kiero
//
//  Created by 안치욱 on 3/6/26.
//

import SwiftUI

enum TodayStatus: String, Decodable {
    case complete = "COMPLETE"
    case failed = "FAILED"
    case skipped = "SKIPPED"
    case verified = "VERIFIED"
    case pending = "PENDING"
}

struct ScheduleBox: View {
    let schedule: TodayScheduleDTO
    let isFireLitToday: Bool
    let showsNextScheduleText: Bool
    let onTapSchedule: (TodayScheduleDTO) -> Void

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
                if showsNextScheduleText {
                    Text("다음 일정")
                        .font(Font(UIFont.body6_10_R))
                        .foregroundStyle(.gray400)
                }

                Text("\(schedule.startTime)-\(schedule.endTime)")
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(timeColor)
                    .padding(.bottom, 8)

                ScheduleCard(
                    schedule: schedule,
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
        switch schedule.status {
        case .complete, .failed, .skipped:
            return .gray400
        case .verified:
            return .main
        case .pending:
            return .gray800
        }
    }
     
    var dotImage: ImageResource {
        if isFireLitToday {
            return .imgCircleSch1
        }
        
        switch schedule.status {
        case .verified:
            return .imgCircleMain
        case .pending:
            return .imgCircleGray
        default:
            return .imgCircleSch1
        }
    }
    
    var dotGlowColor: Color {
        if isFireLitToday {
            return .schedule1
        }
        
        switch schedule.status {
        case .verified:
            return .main
        case .pending:
            return .gray800
        default:
            return .schedule1
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
