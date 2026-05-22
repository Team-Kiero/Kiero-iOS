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
        
        guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }
        
        let coordinator = AuthCoordinator(
            window: window,
            factory: AppDIContainer.shared
        )
        
        coordinator.start()
    }
}
