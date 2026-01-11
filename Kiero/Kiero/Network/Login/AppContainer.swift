//
//  AppContainer.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//


import Foundation

import Alamofire
import Moya


final class AppContainer {

    static let shared = AppContainer()
    private init() {}

    lazy var provider: MoyaProvider<AuthAPI> = {
        let plugins: [PluginType] = [NetworkLoggerPlugin()]
        let configuration = URLSessionConfiguration.default
        configuration.httpCookieStorage = HTTPCookieStorage.shared
        configuration.httpCookieAcceptPolicy = .always
        configuration.httpShouldSetCookies = true
        let baseProvider = MoyaProvider<AuthAPI>(plugins: plugins)
        let repo = AuthRepository(provider: baseProvider)
        let refresher = TokenRefresher(repo: repo)
        let interceptor = AuthInterceptor(refresher: refresher)
        let session = Session(configuration: configuration, interceptor: interceptor)
        return MoyaProvider<AuthAPI>(session: session, plugins: plugins)
    }()

    lazy var authRepository: AuthRepositoryType = {
        AuthRepository(provider: provider)
    }()
}
