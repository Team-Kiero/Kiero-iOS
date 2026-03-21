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
    let isNext: Bool
    
    var body: some View {
        HStack(alignment: .titleCenter, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(spacing: 8) {
                    DailyJourneyTimelineIndicatorView(isOngoing: isOngoing, status: status, isNext: isNext)
                    DailyJourneyScheduleInfoView(name: name, isOngoing: isOngoing, status: status)
                }
                .alignmentGuide(.titleCenter) { d in
                    d[VerticalAlignment.center]
                }
                
                DailyJourneyScheduleTimeView(
                    startTime: startTime,
                    endTime: endTime,
                    isOngoing: isOngoing,
                    status: status,
                    isNext: isNext
                )
            }
            .layoutPriority(1)
            
            DailyJourneyDashedConnectorView(status: status)
                .alignmentGuide(.titleCenter) { d in d[VerticalAlignment.center] }
            
            DailyJourneyStoneRewardView(stoneType: stoneType, status: status)
                .alignmentGuide(.titleCenter) { d in d[VerticalAlignment.center] }
        }
        .frame(height: 79)
        .padding(.horizontal, 36)
    }
}
