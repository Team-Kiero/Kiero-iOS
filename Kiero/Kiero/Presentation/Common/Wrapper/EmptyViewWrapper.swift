//
//  EmptyViewWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI
import UIKit

struct EmptyViewWrapper: UIViewRepresentable {
    let text: String

    func makeUIView(context: Context) -> EmptyView {
        return EmptyView(text: text)
    }

    func updateUIView(_ uiView: EmptyView, context: Context) { }
}
