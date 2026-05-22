//
//  TabCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/22/26.
//

import UIKit

final class TabCoordinator: Coordinator {
    
    private let factory: ViewControllerFactory
    private let isParent: Bool
    
    init(
        factory: ViewControllerFactory,
        isParent: Bool
    ) {
        self.factory = factory
        self.isParent = isParent
    }
    
    func start() -> UIViewController {
        let tabBarController = factory.makeTabBarViewController(isParent: isParent)
        
        tabBarController.onNotificationTap = { [weak self] navigationController in
            self?.showNotificationFeed(from: navigationController)
        }
        
        return tabBarController
    }
    
//    private func showNotificationFeed(from navigationController: UINavigationController) {
//        let vc = factory.makeNotificationFeedViewController()
//        vc.hidesBottomBarWhenPushed = true
//        
//        navigationController.pushViewController(vc, animated: true)
//    }
    private func showNotificationFeed(from navigationController: UINavigationController) {
        let vc = factory.makeNotificationFeedViewController()
        vc.hidesBottomBarWhenPushed = true

        print("before push:", navigationController.viewControllers.count)

        navigationController.pushViewController(vc, animated: true)

        print("after push:", navigationController.viewControllers.count)
    }
}
