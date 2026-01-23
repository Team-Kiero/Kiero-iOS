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

        let pickRoleVC = AppDIContainer.shared.makePickRoleViewController()
        let nav = UINavigationController(rootViewController: pickRoleVC)

        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav)
        }
    }
}
