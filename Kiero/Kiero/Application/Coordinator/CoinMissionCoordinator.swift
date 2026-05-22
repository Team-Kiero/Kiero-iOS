//
//  CoinMissionCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/21/26.
//


import UIKit

final class CoinMissionCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    
    init(
        navigationController: UINavigationController,
        factory: ViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() -> UIViewController {
        let vc = factory.makeCoinMissionViewController()
        return vc
    }
}
