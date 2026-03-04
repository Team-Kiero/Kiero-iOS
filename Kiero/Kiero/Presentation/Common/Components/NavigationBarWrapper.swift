//
//  NavigationBarWrapper.swift
//  Kiero
//
//  Created by Hyunseo Han on 3/4/26.
//

import SwiftUI

struct NavigationBarWrapper: UIViewRepresentable {
    let type: NavigationBarType
    var onLeftTap: (() -> Void)?
    
    func makeUIView(context: Context) -> NavigationBar {
        let navBar = NavigationBar(type: type)
        navBar.leftButtonAction = onLeftTap
        return navBar
    }
    
    func updateUIView(_ uiView: NavigationBar, context: Context) {}
}
