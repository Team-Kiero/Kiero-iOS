//
//  RepositoryFactory.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import UIKit

protocol RepositoryFactory {
    func makeAuthRepository() -> AuthRepositoryType
}
