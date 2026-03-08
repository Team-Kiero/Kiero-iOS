//
//  ScheduleImageOverlayView.swift
//  Kiero
//
//  Created by 안치욱 on 3/7/26.
//

import SwiftUI
import Kingfisher

struct ScheduleImageOverlayView: View {
    let schedule: TodayScheduleDTO
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            headerView

            imageView
                .padding(.horizontal, 10)
                .padding(.bottom, 10)
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.gray900)
        )
    }
}

private extension ScheduleImageOverlayView {
    var headerView: some View {
        HStack {
            Text(schedule.name)
                .font(Font(UIFont.head3_16_B))
                .foregroundStyle(.white)

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    var imageView: some View {
        if let imageUrl = schedule.imageUrl,
           let url = URL(string: imageUrl) {
            KFImage(url)
                .placeholder {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray800)
                        .frame(height: 280)
                }
                .retry(maxCount: 2, interval: .seconds(1))
                .resizable()
                .scaledToFit()
                .frame(width: 317)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray800)
                .frame(width: 317)
        }
    }
}
