//
//  AuthCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import UIKit

final class AuthCoordinator {
    
    private let window: UIWindow
    private let factory: ViewControllerFactory
    private var navigationController: UINavigationController?
    private var childCoordinators: [any Coordinator] = []
    
    init(
        window: UIWindow,
        factory: ViewControllerFactory
    ) {
        self.window = window
        self.factory = factory
    }
    
    func start() {
        let authGateVC = factory.makeAuthGateViewController()
        
        authGateVC.onRoute = { [weak self] route in
            self?.handleAuthGateRoute(route)
        }
        
        let nav = UINavigationController(rootViewController: authGateVC)
        nav.setNavigationBarHidden(true, animated: false)
        
        self.navigationController = nav
        window.rootViewController = nav
        window.makeKeyAndVisible()
    }
    
    private func handleAuthGateRoute(_ route: AuthGateRoute) {
        switch route {
        case .pickRole:
            break
            
        case .parentOnboarding:
            showParentOnboardingAsRoot()
            
        case .parentTab:
            showParentTab()
            
        case .childTab:
            showChildTab()
        }
    }
    
    private func showParentLogin() {
        let vc = factory.makeParentLoginViewController()
        
        vc.onRoute = { [weak self] route in
            switch route {
            case .parentOnboarding:
                self?.showParentOnboardingAsRoot()
            case .parentTab:
                self?.showParentTab()
            case .toast(let message):
                Toast.show(message: message, bottomInset: 83)
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showChildrenLogin() {
        let vc = factory.makeChildrenLoginViewController()
        
        vc.onRoute = { [weak self] route in
            switch route {
            case .childOnboarding:
                self?.showChildOnboarding()
            }
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showChildOnboarding() {
        let vc = factory.makeChildOnboardingViewController()
        
        vc.onFinish = { [weak self] in
            self?.showChildLoadingThenTab()
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func showParentOnboardingAsRoot() {
        let vc = factory.makeParentOnboardingViewController()
        
        vc.onRoute = { [weak self] route in
            switch route {
            case .invite(let last, let first, let inviteCode, let issuedAt):
                self?.showParentInvite(
                    childLastName: last,
                    childFirstName: first,
                    inviteCode: inviteCode,
                    issuedAt: issuedAt
                )
            case .logout:
                self?.restart()
            }
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        changeRoot(nav)
        self.navigationController = nav
    }
    
    private func showParentInvite(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date
    ) {
        let vc = factory.makeParentInviteViewController(
            childLastName: childLastName,
            childFirstName: childFirstName,
            inviteCode: inviteCode,
            issuedAt: issuedAt
        )
        
        vc.onRoute = { [weak self] _ in
            self?.showParentTab()
        }
        
        let nav = UINavigationController(rootViewController: vc)
        nav.setNavigationBarHidden(true, animated: false)
        changeRoot(nav)
        self.navigationController = nav
    }
    
    private func showChildLoadingThenTab() {
        let loadingVC = factory.makeChildLoadingViewController()
        loadingVC.modalPresentationStyle = .fullScreen
        
        navigationController?.present(loadingVC, animated: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            self?.showChildTab()
        }
    }
    
    private func showParentTab() {
        let coordinator = TabCoordinator(factory: factory, isParent: true)
        
        childCoordinators.append(coordinator)
        changeRoot(coordinator.start())
    }

    private func showChildTab() {
        let coordinator = TabCoordinator(factory: factory, isParent: false)
        
        childCoordinators.append(coordinator)
        changeRoot(coordinator.start())
    }
    
    private func restart() {
        start()
    }
    
    private func changeRoot(_ vc: UIViewController) {
        window.rootViewController = vc
        
        UIView.transition(
            with: window,
            duration: 0.5,
            options: [.transitionCrossDissolve],
            animations: nil
        )
    }
}
