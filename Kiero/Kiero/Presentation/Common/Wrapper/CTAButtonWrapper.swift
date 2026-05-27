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
    
    var enabledStyle: CTAButton.Style? = nil
    var disabledStyle: CTAButton.Style? = nil
    var isEnabled: Bool = true
    var onTap: (() -> Void)?
    
    private var currentStyle: CTAButton.Style {
        guard let enabledStyle,
              let disabledStyle else {
            return style
        }
        
        return isEnabled ? enabledStyle : disabledStyle
    }
    
    var body: some View {
        Button {
            guard isEnabled else { return }
            onTap?()
        } label: {
            Text(title)
                .font(Font(size.typo.font))
                .foregroundColor(Color(currentStyle.titleColor))
                .frame(maxWidth: .infinity)
                .frame(height: size.height)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(currentStyle.backgroundColor))
                )
        }
        .disabled(!isEnabled)
    }
}
