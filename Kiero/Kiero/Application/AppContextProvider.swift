//
//  AppContextProvider.swift
//  Kiero
//
//  Created by 안치욱 on 2/25/26.
//

import Foundation

protocol AppContextProviding {
    var userName: String { get }
    var selectedChildId: Int { get }
    func setSelectedChildId(_ id: Int)
}

final class DefaultAppContextProvider: AppContextProviding {
    var userName: String {
        TokenManager.shared.getFirstName() ?? "사용자"
    }

    var selectedChildId: Int {
        UserDefaults.standard.integer(forKey: "selectedChildId")
    }
    
    func setSelectedChildId(_ id: Int) {
        UserDefaults.standard.set(id, forKey: "selectedChildId")
    }
}
