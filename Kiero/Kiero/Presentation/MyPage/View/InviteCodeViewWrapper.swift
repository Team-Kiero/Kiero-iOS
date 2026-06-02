//
//  InviteCodeViewWrapper.swift
//  Kiero
//
//  Created by 안치욱 on 5/24/26.
//

import SwiftUI

struct InviteCodeViewWrapper: UIViewRepresentable {
    let code: String
    let remainingTime: String
    let isExpired: Bool
    var refreshDidTap: (() -> Void)?
    
    func makeUIView(context: Context) -> InviteCodeView {
        let view = InviteCodeView()
        view.refreshDidTap = refreshDidTap
        return view
    }
    
    func updateUIView(_ uiView: InviteCodeView, context: Context) {
        uiView.configure(
            code: code,
            remainingTime: remainingTime,
            isExpired: isExpired
        )
        uiView.refreshDidTap = refreshDidTap
    }
}
