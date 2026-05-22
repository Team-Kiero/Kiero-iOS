//
//  UserSessionStorage.swift
//  Kiero
//
//  Created by 안치욱 on 5/1/26.
//

import Foundation

protocol UserSessionStorageType {
    var selectedChildId: Int { get set }
    var firstName: String? { get }
    var recentActivityIds: [Int] { get set }
}

final class UserSessionStorage: UserSessionStorageType {
    
    var selectedChildId: Int {
        get {
            UserDefaults.standard.integer(forKey: "selectedChildId")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedChildId")
        }
    }
    
    var firstName: String? {
        TokenManager.shared.getFirstName()
    }
    
    var recentActivityIds: [Int] {
        get {
            UserDefaults.standard.array(forKey: "recentActivityIds") as? [Int] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "recentActivityIds")
        }
    }
}
