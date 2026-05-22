//
//  MySpaceCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/22/26.
//

import Combine
import SwiftUI
import UIKit

final class MySpaceCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    private let logoutService: LogoutServiceType
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        navigationController: UINavigationController,
        factory: ViewControllerFactory,
        logoutService: LogoutServiceType
    ) {
        self.navigationController = navigationController
        self.factory = factory
        self.logoutService = logoutService
    }
    
    func start() -> UIViewController {
        let vc = MySpaceHostingController()
        
        vc.onWishSpaceTap = { [weak self] in
            self?.showWishSpace()
        }
        
        vc.onTermsTap = { [weak self] in
            self?.showTerms()
        }
        
        vc.onLogoutConfirm = { [weak self] in
            self?.logout()
        }
        
        return vc
    }
    
    private func showWishSpace() {
        print("소원의 공간 이동")
    }
    
    private func showTerms() {
        let vc = UIHostingController(rootView: TermsView())
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func logout() {
        logoutService.logout()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .finished = completion {
                    LogoutHelper.logoutToPickRole()
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
}
