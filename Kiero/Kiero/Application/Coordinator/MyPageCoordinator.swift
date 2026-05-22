//
//  MyPageCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import UIKit

final class MyPageCoordinator: Coordinator {
    
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
        let vc = factory.makeMyPageViewController()
        
        vc.onChildConnectionTap = {
            print("자녀 연결 관리")
        }
        
        vc.onLogoutConfirm = { [weak vc] in
            vc?.viewModel.requestLogout()
        }
        
        return vc
    }
}
