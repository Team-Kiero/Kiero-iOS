//
//  NavigationBarWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/3/26.
//

import SwiftUI
import UIKit

struct NavigationBarWrapper: UIViewRepresentable {
    
    // MARK: - Properties
    
    let type: NavigationBarType
    var title: String? = nil
    var isRightButtonEnabled: Bool = true
    var isNotificationActive: Bool = false
    
    var onLeftTap: (() -> Void)?
    var onRightTap: (() -> Void)?

    func makeUIView(context: Context) -> NavigationBar {
        let view = NavigationBar(type: type)
        
        view.leftButtonAction = {
            onLeftTap?()
        }
        
        view.rightButtonAction = {
            onRightTap?()
        }
        
        return view
    }

    func updateUIView(_ uiView: NavigationBar, context: Context) {
        uiView.isRightButtonEnabled = isRightButtonEnabled
        uiView.isNotificationActive = isNotificationActive
        
        if let title = title {
            uiView.updateTitle(title)
        }
    }
}
