//
//  SceneDelegate.swift
//  Kiero
//
//  Created by 신혜연 on 1/4/26.
//

import UIKit

import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    private var authCoordinator: AuthCoordinator?
    
    func scene(
            _ scene: UIScene,
            willConnectTo session: UISceneSession,
            options connectionOptions: UIScene.ConnectionOptions
        ) {
            guard let windowScene = scene as? UIWindowScene else { return }
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            let coordinator = AuthCoordinator(
                window: window,
                factory: AppDIContainer.shared
            )
            self.authCoordinator = coordinator
            coordinator.start()
        }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if AuthApi.isKakaoTalkLoginUrl(url) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
        
        if animated {
            UIView.transition(
                with: window,
                duration: 0.5,
                options: [.transitionCrossDissolve],
                animations: nil
            )
        }
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        SseStreamManager.shared.resume()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        SseStreamManager.shared.pause()
    }
}
