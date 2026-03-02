//
//  DailyJourneyMapStateRowView.swift
//  Kiero_Child
//
//  Created by Hyunseo Han on 3/2/26.
//

import SwiftUI

extension VerticalAlignment {
    private enum TitleCenterAlignment: AlignmentID {
        static func defaultValue(in d: ViewDimensions) -> CGFloat {
            return d[VerticalAlignment.center]
        }
    }
    static let titleCenter = VerticalAlignment(TitleCenterAlignment.self)
}

struct DailyJourneyMapStateRowView: View {
    let name: String
    let startTime: String
    let endTime: String
    let isOngoing: Bool
    let stoneType: String
    let status: String
    
    var body: some View {
        HStack(alignment: .titleCenter, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(spacing: 8) {
                    DailyJourneyTimelineIndicatorView(isOngoing: isOngoing, status: status)
                    DailyJourneyScheduleInfoView(name: name, isOngoing: isOngoing, status: status)
                }
                .alignmentGuide(.titleCenter) { d in
                    d[VerticalAlignment.center]
                }
                
                DailyJourneyScheduleTimeView(
                    startTime: startTime,
                    endTime: endTime,
                    isOngoing: isOngoing,
                    status: status
                )
            }
            .layoutPriority(1)
            
            DailyJourneyDashedConnectorView(isOngoing: isOngoing, status: status)
                .alignmentGuide(.titleCenter) { d in d[VerticalAlignment.center] }
            
            DailyJourneyStoneRewardView(stoneType: stoneType, status: status)
                .alignmentGuide(.titleCenter) { d in d[VerticalAlignment.center] }
        }
        .padding(.horizontal, 36)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.kBlack
        VStack (spacing: 50) {
            
            // 완료
            DailyJourneyMapStateRowView(
                name: "임상헌 마라탕먹기",
                startTime: "13:00",
                endTime: "15:00",
                isOngoing: false,
                stoneType: "GRIT",
                status: "FAILED",
            )
            
            // 진행중 + 획득
            DailyJourneyMapStateRowView(
                name: "꾸비 성수팝업 가기",
                startTime: "16:00",
                endTime: "17:00",
                isOngoing: true,
                stoneType: "COURAGE",
                status: "COMPLETE",
            )
            
            // 예정
            DailyJourneyMapStateRowView(
                name: "원준이 생일파티",
                startTime: "19:00",
                endTime: "19:30",
                isOngoing: false,
                stoneType: "WISDOM",
                status: "PENDING",
            )
        }
    }
}
