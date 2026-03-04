//
//  LogoutHelper.swift
//  Kiero
//
//  Created by 안치욱 on 1/23/26.
//

import UIKit

enum LogoutHelper {
    static func logoutToPickRole() {
        TokenManager.shared.clearAll()
        AppDIContainer.shared.sseManager.stop()

        let authVC = AuthGateViewController()
        let nav = UINavigationController(rootViewController: authVC)

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav)
        }
    }
}
