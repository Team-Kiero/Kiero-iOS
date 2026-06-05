//
//  AppDelegate.swift
//  Kiero
//
//  Created by 신혜연 on 1/4/26.
//

import UIKit
import UserNotifications

import KakaoSDKCommon
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate,
                   UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 카카오 SDK
        KakaoSDK.initSDK(appKey: Config.kakaoAppKey)
        
        // Firebase 초기화
        let googleServiceFileName: String
        
        if Bundle.main.bundleIdentifier == "com.Kiero.Parent" {
            googleServiceFileName = "GoogleService-Info-Parent"
        } else {
            googleServiceFileName = "GoogleService-Info-Child"
        }
        
        if let filePath = Bundle.main.path(forResource: googleServiceFileName, ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: options)
            NSLog("✅ Firebase 초기화 성공: %@", googleServiceFileName)
        } else {
            NSLog("❌ GoogleService-Info.plist를 찾을 수 없음")
        }
        
        UNUserNotificationCenter.current().delegate = self
        
        application.registerForRemoteNotifications()
        
        Messaging.messaging().delegate = self
        
        if let userInfo = launchOptions?[.remoteNotification] as? [String: Any] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.handleNotification(userInfo)
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        NSLog("✅ APNs 토큰 수신: %@", tokenString)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        NSLog("❌ APNs 등록 실패: %@", error.localizedDescription)
    }
    
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        
        NSLog("🔥 FCM Token: %@", token)
        
        FCMTokenManager.shared.saveToken(token)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        handleNotification(userInfo)
        completionHandler()
    }
    
    private func handleNotification(_ userInfo: [AnyHashable: Any]) {
        let type = userInfo["type"] as? String
        let targetId = userInfo["targetId"] as? String
        
        Task { @MainActor in
            DeepLinkManager.shared.handle(type: type, targetId: targetId)
        }
    }
    
    // MARK: - UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication,
                     didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
