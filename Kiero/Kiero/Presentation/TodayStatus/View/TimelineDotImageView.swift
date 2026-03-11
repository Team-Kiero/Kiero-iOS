//
//  TimelineDotImageView.swift
//  Kiero
//
//  Created by 안치욱 on 3/8/26.
//

import SwiftUI

struct TimelineDotImageView: View {
    let image: ImageResource
    let glowColor: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(glowColor.opacity(0.48))
                .frame(width: 10, height: 10)
                .blur(radius: 4)
            
            Image(image)
                .resizable()
                .scaledToFit()
                .frame(width: 7, height: 7)
        }
        .frame(width: 12, height: 12)
    }
}
