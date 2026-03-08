//
//  CTAButtonWrapper.swift
//  Kiero
//
//  Created by Hyunseo Han on 3/4/26.
//

import SwiftUI

struct CTAButtonWrapper: View {
    let title: String
    let style: CTAButton.Style
    let size: CTAButton.Size
    var onTap: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onTap?()
        }) {
            Text(title)
                .font(Font(size.typo.font))
                .foregroundColor(Color(style.titleColor))
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(style.backgroundColor))
                )
        }
    }
}
