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
            let isNewToken = UserDefaults.standard.string(forKey: "fcmToken") != token
            UserDefaults.standard.set(token, forKey: "fcmToken")
            
            guard TokenManager.shared.getAccessToken() != nil else {
                print("📱 [FCM] 토큰 수신 및 로컬 저장 완료")
                return
            }
            
            if isNewToken {
                print("📱 [FCM] 로그인 상태에서 새 토큰 발급 → 서버 전송")
                Task {
                    await sendTokenToServer(token)
                }
            }
        }
    
    func getToken() -> String? {
        UserDefaults.standard.string(forKey: "fcmToken")
    }
    
    func sendCurrentTokenToServer() async {
            guard let token = getToken() else {
                print("❌ [FCM] 서버에 보낼 로컬 저장된 토큰이 없습니다.")
                return
            }
            print("📱 [FCM] 로그인 성공 확인 → 현재 토큰 서버 전송 시작")
            await sendTokenToServer(token)
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
