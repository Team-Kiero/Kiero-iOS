//
//  FCMTokenManager.swift
//  Kiero
//
//  Created by 정윤아 on 5/27/26.
//

import Foundation

final class FCMTokenManager {
    static let shared = FCMTokenManager()
    private init() {}
    
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "fcmToken")
    }
    
    func getToken() -> String? {
        UserDefaults.standard.string(forKey: "fcmToken")
    }
    
    func sendTokenToServer(_ token: String) async {
        do {
            let body = FCMTokenRequest(fcmToken: token)
            let _: EmptyResponse = try await BaseService.shared.request(
                endPoint: .updateFCMToken,
                body: body
            )
            print("✅ FCM 토큰 서버 전송 성공")
        } catch {
            print("❌ FCM 토큰 서버 전송 실패: \(error)")
        }
    }
}
