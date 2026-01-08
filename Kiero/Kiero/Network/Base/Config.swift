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
}
