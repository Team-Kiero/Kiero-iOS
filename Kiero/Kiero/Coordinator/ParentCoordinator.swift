//
//  ParentCoordinator.swift
//  Kiero
//
//  Created by 신혜연 on 7/4/26.
//

import UIKit

final class ParentCoordinator: Coordinator {
    let navigationController: UINavigationController
    private let diContainer: ViewControllerFactory
    var onRequestRootChange: ((UIViewController) -> Void)?

    init(navigationController: UINavigationController, diContainer: ViewControllerFactory) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        showParentLogin()
    }
}

// MARK: - PickRole

extension ParentCoordinator {
    func showPickRole() {
        let vc = diContainer.makePickRoleViewController() as! PickRoleViewController
        vc.onSelectParent = { [weak self] in self?.showParentLogin() }
        vc.onSelectChild = { [weak self] in /* 별도 스텝 */ }
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - ParentLogin

extension ParentCoordinator {
    func showParentLogin(pendingRequiredTerms terms: [RequiredTerm]? = nil) {
        let vc = diContainer.makeParentLoginViewController() as! ParentLoginViewController
        vc.pendingRequiredTerms = terms
        
        vc.onFinishOnboarding = { [weak self] in
            guard let self else { return }
            let onboardingVC = self.diContainer.makeParentOnboardingViewController() as! ParentOnboardingViewController
            self.setupOnboarding(onboardingVC)
            self.onRequestRootChange?(onboardingVC)
        }
        
        vc.onFinishLogin = { [weak self] in
            guard let self else { return }
            let tab = TabBarViewController(factory: self.diContainer, isParent: true)
            self.onRequestRootChange?(tab)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showParentOnboardingDirectly() {
        let onboardingVC = diContainer.makeParentOnboardingViewController() as! ParentOnboardingViewController
        setupOnboarding(onboardingVC)
        onRequestRootChange?(onboardingVC)
    }
}

// MARK: - ParentOnboarding

extension ParentCoordinator {
    private func setupOnboarding(_ vc: ParentOnboardingViewController) {
        vc.onInvite = { [weak self] last, first, inviteCode, issuedAt in
            guard let self else { return }
            let inviteVC = self.diContainer.makeParentInviteViewController(
                childLastName: last,
                childFirstName: first,
                inviteCode: inviteCode,
                issuedAt: issuedAt
            ) as! ParentInviteViewController
            
            self.setupInvite(inviteVC)
            
            let nav = UINavigationController(rootViewController: inviteVC)
            self.onRequestRootChange?(nav)
        }
        
        vc.onLogout = { [weak self] in
            LogoutHelper.logoutToPickRole()
        }
    }
}

// MARK: - ParentInvite

extension ParentCoordinator {
    private func setupInvite(_ vc: ParentInviteViewController) {
        vc.onFinish = { [weak self] in
            guard let self else { return }
            let tab = TabBarViewController(factory: self.diContainer, isParent: true)
            self.onRequestRootChange?(tab)
        }
        
        vc.onLogout = { [weak self] in
            LogoutHelper.logoutToPickRole()
        }
    }
}
