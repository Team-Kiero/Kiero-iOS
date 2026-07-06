//
//  ChildCoordinator.swift
//  Kiero
//
//  Created by 신혜연 on 7/6/26.
//

import UIKit

final class ChildCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let diContainer: ViewControllerFactory
    var onRequestRootChange: ((UIViewController) -> Void)?

    init(navigationController: UINavigationController, diContainer: ViewControllerFactory) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        showChildLogin()
    }
}

extension ChildCoordinator {
    func showChildLogin() {
        let vc = diContainer.makeChildrenLoginViewController() as! ChildrenLoginViewController
        
        vc.onFinishSignup = { [weak self] in
            guard let self else { return }
            let onboardingVC = self.diContainer.makeChildOnboardingViewController() as! ChildrenOnboardingViewController
            
            onboardingVC.onFinish = { [weak self] in
                guard let self else { return }
                let tab = TabBarViewController(factory: self.diContainer, isParent: false)
                self.onRequestRootChange?(tab)
            }
            
            self.navigationController.pushViewController(onboardingVC, animated: true)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}
