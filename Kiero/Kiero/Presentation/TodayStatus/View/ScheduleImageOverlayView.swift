//
//  ScheduleImageOverlayView.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI

import Kingfisher

struct ScheduleImageOverlayView: View {
    let schedule: ScheduleItem
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {

            NavigationBarWrapper(
                type: .titleClose(title: schedule.title),
                onRightTap: onClose
            )
            .frame(height: 40)
            .padding(.top, 16)

            KFImage(schedule.imageURL)
                .placeholder {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray800)
                        .frame(height: 280)
                }
                .retry(maxCount: 2, interval: .seconds(1))
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .padding(.horizontal, 13)
                .padding(.top, 20)
                .padding(.bottom, 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray900)
        )
    }
}
