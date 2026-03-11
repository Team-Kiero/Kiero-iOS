//
//  StatusEmptyView.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI

enum EmptyType {
    case scheduleEmpty
    case missionEmpty
    case missionComplete
}

extension EmptyType {
    var emptyText: String {
        switch self {
        case .scheduleEmpty:
            return "오늘 등록된 일정이 없어요."
        case .missionEmpty:
            return "아직 완료된 미션이 없어요."
        case .missionComplete:
            return "남은 미션이 없어요! 모두 완료했어요."
        }
    }
}

struct StatusEmptyView: View {
    let type: EmptyType
    
    var body: some View {
        VStack (spacing: 0){
            Image(.icScheduleEmpty)
                .resizable()
                .frame(width: 69, height: 52)
            
            Text(type.emptyText)
                .font(Font(UIFont.title3_16_SB))
                .foregroundStyle(.gray600)
                .padding(.top, 11)
            
            if type == .scheduleEmpty {
                Text("일정을 등록해 주세요.")
                    .font(Font(UIFont.body4_12_R))
                    .foregroundStyle(.gray700)
                    .padding(.top, 4)
            }
        }
    }
}
