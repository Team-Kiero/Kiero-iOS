//
//  ScheduleCompleteFooterView.swift
//  Kiero
//
//  Created by 안치욱 on 3/8/26.
//

import SwiftUI

struct ScheduleCompleteFooterView: View {
    let dotImage: ImageResource

    var body: some View {
        HStack(alignment: .center, spacing: 5) {
            Image(dotImage)
                .resizable()
                .scaledToFit()
                .frame(width: 7, height: 7)
                .shadow(color: .schedule1.opacity(0.9), radius: 8)
                .shadow(color: .schedule1.opacity(0.5), radius: 16)
                .frame(width: 20)

            Text("오늘 일정이 모두 완료되었어요.")
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.gray400)

            Spacer()
        }
    }
}
