//
//  FloatingButtonWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI
import UIKit

struct FloatingButtonWrapper: UIViewRepresentable {
    var type: FloatingButtonType
    var action: () -> Void

    func makeUIView(context: Context) -> FloatingButton {
        let button = FloatingButton(type: type)
        button.tapAction = action
        return button
    }

    func updateUIView(_ uiView: FloatingButton, context: Context) {
        uiView.updateType(type)
    }
}
