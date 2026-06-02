//
//  LoginState.swift
//  Kiero
//
//  Created by 안치욱 on 1/11/26.
//

enum LoginState: Equatable {
    case idle
    case loading
    case failure(String)
}

enum LoginRoute {
    case parentOnboarding
    case parentTab
    case toast(String)
    case requiredTerms([RequiredTerm])
}
