//
//  Config.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import Foundation

enum Config {
    enum Keys {
        enum Plist {
            static let BASE_URL = "BASE_URL"
            static let KAKAO_NATIVE_APP_KEY = "KAKAO_NATIVE_APP_KEY"
            static let AMPLITUDE_API_KEY_DEV = "AMPLITUDE_API_KEY_DEV"
            static let AMPLITUDE_API_KEY_PROD = "AMPLITUDE_API_KEY_PROD"
#if KIERO_PARENT
            static let APPSTORE_ID = "PARENT_APPSTORE_ID"
#elseif KIERO_CHILD
            static let APPSTORE_ID = "CHILD_APPSTORE_ID"
#endif
        }
    }
    
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found")
        }
        return dict
    }()
}

extension Config {
    static let baseURL: String = {
        guard let key = Config.infoDictionary[Keys.Plist.BASE_URL] as? String else {
            fatalError("BASE_URL is not set in plist for this configuration")
        }
        return key
    }()
    
    static let apiBaseURL: URL = {
        guard let url = URL(string: baseURL) else {
            fatalError("구성된 BASE_URL이 유효한 URL 형식이 아닙니다: \(baseURL)")
        }
        return url
    }()
    
    static let kakaoAppKey: String = {
        guard let key = Config.infoDictionary[Keys.Plist.KAKAO_NATIVE_APP_KEY] as? String else {
            fatalError("KAKAO_NATIVE_APP_KEY is not set in plist for this configuration")
        }
        return key
    }()
    
    static let amplitudeAPIKey: String = {
        #if DEBUG
        let plistKey = Keys.Plist.AMPLITUDE_API_KEY_DEV
        #else
        let plistKey = Keys.Plist.AMPLITUDE_API_KEY_PROD
        #endif

        guard let key = Config.infoDictionary[plistKey] as? String else {
            fatalError("\(plistKey) is not set in plist for this configuration")
        }
        return key
    }()

    static let sseURL: URL = {
        guard let url = URL(string: baseURL + "/api/v1/subscribe") else {
            fatalError("구성된 SSE_URL이 유효한 URL 형식이 아닙니다: \(baseURL)")
        }
        return url
    }()
    
    static let appStoreURL: URL = {
        guard let appStoreID = Config.infoDictionary[Keys.Plist.APPSTORE_ID] as? String,
              let url = URL(string: "itms-apps://itunes.apple.com/us/app/id\(appStoreID)") else {
            fatalError("APPSTORE_ID가 유효하지 않습니다.")
        }
        return url
    }()
}
