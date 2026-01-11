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
        return "http://" + key
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
}
