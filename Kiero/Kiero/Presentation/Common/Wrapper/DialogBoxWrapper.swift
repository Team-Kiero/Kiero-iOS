//
//  DialogBoxWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/2/26.
//

import SwiftUI
import UIKit

struct DialogBoxView: View {
    var state: DialogBox.State
    @Binding var isPresented: Bool
    var onConfirm: (() -> Void)?

    var body: some View {
        DialogBoxWrapper(state: state, isPresented: $isPresented, onConfirm: onConfirm)
            .frame(width: 343)
    }
}

private struct DialogBoxWrapper: UIViewRepresentable {
    var state: DialogBox.State
    @Binding var isPresented: Bool
    var onConfirm: (() -> Void)?

    func makeUIView(context: Context) -> DialogBox {
        let view = DialogBox()

        view.onTapClose = {
            isPresented = false
        }

        view.onTapCancel = {
            isPresented = false
        }

        view.onTapConfirm = {
            onConfirm?()
            isPresented = false
        }

        return view
    }

    func updateUIView(_ uiView: DialogBox, context: Context) {
        uiView.configure(state: state)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: DialogBox, context: Context) -> CGSize? {
        let width: CGFloat = 343
        let size = uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return CGSize(width: width, height: size.height)
    }
}
