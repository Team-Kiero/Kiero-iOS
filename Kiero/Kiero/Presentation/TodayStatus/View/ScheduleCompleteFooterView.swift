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
            ZStack {
                Circle()
                    .fill(Color.schedule1.opacity(0.48))
                    .frame(width: 14, height: 14)
                    .blur(radius: 4)

                Image(dotImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 7, height: 7)
            }
            .frame(width: 12, height: 12)
            .frame(width: 20, alignment: .center)

            Text("오늘 일정이 모두 완료되었어요.")
                .font(Font(UIFont.body4_12_R))
                .foregroundStyle(.gray400)

            Spacer()
        }
    }
}
