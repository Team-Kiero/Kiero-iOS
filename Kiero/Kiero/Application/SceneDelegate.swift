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
    private var isUpdateAlertPresented = false
    
#if KIERO_PARENT
    var parentCoordinator: ParentCoordinator?
#endif
    
#if KIERO_CHILD
    var childCoordinator: ChildCoordinator?
#endif

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)

        let authGate = AuthGateViewController()
        let nav = UINavigationController(rootViewController: authGate)
        nav.setNavigationBarHidden(true, animated: false)

        window.rootViewController = nav
        self.window = window
        window.makeKeyAndVisible()
    }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
        }
    }
    
    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController = vc
        
        if animated {
            UIView.transition(with: window,
                              duration: 0.5,
                              options: [.transitionCrossDissolve],
                              animations: nil,
                              completion: nil)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        checkAppUpdate()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        SseStreamManager.shared.resume()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        SseStreamManager.shared.pause()
    }
}

private extension SceneDelegate {
    
    func checkAppUpdate() {
        Task { @MainActor in
            let updateType = await AppUpdateManager.shared.checkForUpdate()
            handleUpdate(updateType)
        }
    }
    
    func handleUpdate(_ updateType: AppUpdateType) {
        switch updateType {
        case .none:
            break
            
        case .optional:
            showOptionalUpdateAlert()
            
        case .required:
            showRequiredUpdateAlert()
        }
    }
    
    func showOptionalUpdateAlert() {
        guard !isUpdateAlertPresented else { return }
        guard let viewController = topViewController() else { return }
        
        isUpdateAlertPresented = true
        
        let alert = UIAlertController(title: "새로운 업데이트",
                                      message: "새로운 버전이 출시되었어요.\n업데이트하시겠어요?",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "나중에", style: .cancel) { [weak self] _ in
            self?.isUpdateAlertPresented = false
        })
        
        alert.addAction(UIAlertAction(title: "업데이트", style: .default) { [weak self] _ in
            self?.isUpdateAlertPresented = false
            self?.openAppStore()
        })
        
        viewController.present(alert, animated: true)
    }
    
    func showRequiredUpdateAlert() {
        guard !isUpdateAlertPresented else { return }
        guard let viewController = topViewController() else { return }
        
        isUpdateAlertPresented = true
        
        let alert = UIAlertController(title: "필수 업데이트",
                                      message: "서비스 이용을 위해\n최신 버전으로 업데이트해 주세요.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "업데이트", style: .default) { [weak self] _ in
            self?.openAppStore()
        })
        
        viewController.present(alert, animated: true)
    }
    
    func openAppStore() {
        print(Config.appStoreURL)
        UIApplication.shared.open(Config.appStoreURL)
    }
    
    func topViewController(from viewController: UIViewController? = nil) -> UIViewController? {
        let current = viewController ?? window?.rootViewController
        
        if let navigationController = current as? UINavigationController {
            return topViewController(from: navigationController.visibleViewController)
        }
        
        if let tabBarController = current as? UITabBarController {
            return topViewController(from: tabBarController.selectedViewController)
        }
        
        if let presentedViewController = current?.presentedViewController {
            return topViewController(from: presentedViewController)
        }
        
        return current
    }
}
