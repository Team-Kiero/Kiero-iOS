//
//  AppDIContainer.swift
//  Kiero
//
//  Created by 신혜연 on 1/8/26.
//

import UIKit

final class AppDIContainer: ViewControllerFactory, ViewModelFactory, ServiceFactory {
    
    static let shared = AppDIContainer()
    private init() {}
    
    var appContext: AppContextProviding = DefaultAppContextProvider()
    lazy var sseManager: SseStreamManager = SseStreamManager.shared
    lazy var tokenStore: TokenStoring = TokenManager.shared
    lazy var tokenRefresher: TokenRefreshing = TokenRefresher(tokenStore: tokenStore)
    lazy var networkService: NetworkServicing = BaseService(tokenRefresher: tokenRefresher)
}
