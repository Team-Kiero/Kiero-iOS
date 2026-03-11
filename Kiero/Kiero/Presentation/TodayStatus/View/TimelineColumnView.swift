//
//  TimelineColumnView.swift
//  Kiero
//
//  Created by 안치욱 on 3/8/26.
//

import SwiftUI

struct TimelineColumnView: View {
    let dotImage: ImageResource
    let dotGlowColor: Color
    let lineGradient: LinearGradient
    let lineHeight: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Image(dotImage)
                .resizable()
                .scaledToFit()
                .frame(width: 7, height: 7)
                .shadow(color: dotGlowColor.opacity(0.9), radius: 8)
                .shadow(color: dotGlowColor.opacity(0.5), radius: 16)
            DashedVerticalLine()
                .stroke(
                    lineGradient,
                    style: StrokeStyle(
                        lineWidth: 1,
                        lineCap: .round,
                        dash: [2, 3]
                    )
                )
                .frame(width: 1, height: lineHeight)
                .padding(.top, 4)
        }
        .frame(width: 20)
    }
}
