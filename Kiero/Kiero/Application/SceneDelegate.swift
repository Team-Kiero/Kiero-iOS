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


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let items: [SpeechItem] = [
            .init(image: .imgStory1, name: "꾸비", lines: ["드디어 만났다! 나의 짝꿍 근영", "난 꼬마 히어로 꾸비야. 우리 같이 모험을 떠나볼까?"], highlightKeywords: []),
            .init(image: .imgStory2, name: "꾸비", lines: ["다른 도깨비들은 장난치는 걸 좋아하지만,", "난 '영웅의 불씨'를 품고 태어난 특별한 도깨비야!", "너의 노력을 멋진 소원으로 바꾸는 꼬마 히어로 지"], highlightKeywords: ["꼬마 히어로"]),
            .init(image: .imgStory3, name: "꾸비", lines: ["그런데 큰일이야...", "배에 있는 ‘영웅의 불씨'가 자꾸 꺼지려고 해.", "나 혼자서는 지킬 수 없거든", "오직 너만이 이 불씨를 다시 키울 수 있어!"], highlightKeywords: ["오직 너만이 이 불씨를 다시 키울 수 있어!"]),
            .init(image: .imgStory4, name: "꾸비", lines: ["오늘의 여정을 따라 하루를 보내고", "불조각을 나에게 건네줘!", "너가 준 [용기, 인내, 지혜의 불조각] 이", "내 마음의 불꽃을 키워줄거야."], highlightKeywords: ["[용기, 인내, 지혜의 불조각]"]),
            .init(image: .imgStory5, name: "꾸비", lines: ["그 힘으로 내가 반짝이는 금화를 만들어줄게!", "소원의 우물에서 금화를 통해", "너의 소원을 이룰 수 있을거야!"], highlightKeywords: [])
        ]
        let vc = UINavigationController(rootViewController: ChildOnboardingViewController(viewModel: ChildOnboardingViewModel(items: items), diContainer: AppDIContainer.shared))
        window.rootViewController = vc
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

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

