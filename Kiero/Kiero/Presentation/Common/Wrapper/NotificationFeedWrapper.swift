//
//  NotificationFeedWrapper.swift
//  Kiero
//
//  Created by 정윤아 on 3/4/26.
//

import SwiftUI

struct NotificationFeedWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return AppDIContainer.shared.makeNotificationFeedViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
}
