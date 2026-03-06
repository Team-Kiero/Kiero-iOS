//
//  ChipItemWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI
import UIKit

struct ChipItemWrapper: UIViewRepresentable {
    let style: ChipItem.ChipStyle
    let icon: UIImage
    let text: String
    
    func makeUIView(context: Context) -> ChipItem {
        let chip = ChipItem()
        chip.setContentHuggingPriority(.required, for: .horizontal)
        chip.setContentHuggingPriority(.required, for: .vertical)
        return chip
    }
    
    func updateUIView(_ uiView: ChipItem, context: Context) {
        uiView.configure(style: style, icon: icon, text: text)
    }
}
