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
            if schedule.imageURL != nil {
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
                
                if schedule.imageURL != nil {
                    Image(.icPhoto)
                        .renderingMode(.template)
                        .foregroundStyle(photoIconColor)
                    
                    Image(.icRight)
                        .renderingMode(.template)
                        .foregroundStyle(chevronColor)
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
        switch schedule.status {
        case .complete:
            return .gray800
        case .failed, .skipped:
            return .point
        case .verified:
            return .main
        case .pending:
            return .gray800
        }
    }
    
    var textColor: Color {
        switch schedule.status {
        case .complete, .failed, .skipped:
            return .gray400
        case .verified:
            return .main
        case .pending:
            return .gray800
        }
    }
    
    var showsPhotoIcon: Bool {
        switch schedule.status {
        case .failed, .skipped:
            return false
        case .complete, .verified, .pending:
            return schedule.imageURL != nil
        }
    }
    
    var showsChevronIcon: Bool {
        switch schedule.status {
        case .failed, .skipped:
            return false
        case .complete, .verified, .pending:
            return schedule.imageURL != nil
        }
    }
    
    var photoIconColor: Color {
        switch schedule.status {
        case .complete:
            return .gray800
        case .verified:
            return .gray400
        case .pending:
            return .gray800
        case .failed, .skipped:
            return .clear
        }
    }
    
    var chevronColor: Color {
        switch schedule.status {
        case .complete:
            return .gray800
        case .verified:
            return .gray400
        case .pending:
            return .gray800
        case .failed, .skipped:
            return .clear
        }
    }
    
    @ViewBuilder
    var backgroundView: some View {
        switch schedule.status {
        case .verified:
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.schedule1.opacity(0.1))
        default:
            Color.clear
        }
    }
}
