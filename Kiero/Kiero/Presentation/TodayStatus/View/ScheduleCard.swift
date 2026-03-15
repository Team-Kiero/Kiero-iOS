//
//  ScheduleCard.swift
//  Kiero
//
//  Created by 안치욱 on 3/6/26.
//

import SwiftUI

struct ScheduleCard: View {
    let schedule: ScheduleItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: {
            if tapAction {
                onTap()
            }
        }) {
            HStack(spacing: 0) {
                Image(buttonName)
                    .padding(.leading, 10)
                
                Text(schedule.title)
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(textColor)
                    .lineLimit(1)
                    .padding(.leading, 8)
                
                Spacer()
                
                if showsIcon {
                    Image(.icPhoto)
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                    
                    Image(.icRight)
                        .renderingMode(.template)
                        .foregroundStyle(iconColor)
                        .padding(.trailing, 10)
                }
            }
            .frame(height: 51)
            .background(backgroundView)
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(borderColor, lineWidth: 1)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .buttonStyle(.plain)
    }
}

private extension ScheduleCard {
    var tapAction: Bool {
        switch schedule.status {
        case .complete, .verified:
            return true
        case .pending, .skipped, .failed:
            return false
        }
    }
    
    var buttonName: ImageResource {
        switch schedule.status {
        case .complete:
            return .btnCheck
        case .failed, .skipped:
            return .btnClosePoint
        case .verified:
            return .btnCheckFill
        case .pending:
            return .btnUncheck
        }
    }
    
    var borderColor: Color {
        if schedule.isNowSchedule {
            return .main
        }
        else {
            switch schedule.status {
            case .complete, .pending, .verified:
                return .gray800
            case .failed, .skipped:
                return .point
            }
        }
    }
    
    var textColor: Color {
        if schedule.isNowSchedule {
            return .main
        }
        else {
            switch schedule.status {
            case .complete, .failed, .skipped:
                return .gray400
            case .verified:
                return .main
            case .pending:
                return .gray800
            }
        }
    }
    
    var showsIcon: Bool {
        switch schedule.status {
        case .failed, .skipped, .pending:
            return false
        case .complete, .verified:
            return true
        }
    }
    
    var iconColor: Color {
        switch schedule.status {
        case .complete:
            return .gray800
        case .verified:
            return .gray400
        case .failed, .skipped, .pending:
            return .clear
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        if schedule.isNowSchedule {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.schedule1.opacity(0.1))
        }
        else {
            Color.clear
        }
    }
}
