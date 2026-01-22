//
//  AuthGateViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/21/26.
//

import Combine
import UIKit

final class AuthGateViewController: UIViewController {

    private let viewModel: AuthGateViewModel
    private var cancellables = Set<AnyCancellable>()

    init(viewModel: AuthGateViewModel = AuthGateViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        viewModel.decideRoute()
    }

    private func bind() {
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                self?.handle(route)
            }
            .store(in: &cancellables)
    }

    private func handle(_ route: AuthGateRoute) {
        switch route {
        case .pickRole:
            let pickRoleVC = AppDIContainer.shared.makePickRoleViewController()
            let nav = UINavigationController(rootViewController: pickRoleVC)
            changeRoot(nav)

        case .parentTab:
            let tab = TabBarViewController(factory: AppDIContainer.shared, isParent: true)
            changeRoot(tab)

        case .childTab:
            let tab = TabBarViewController(factory: AppDIContainer.shared, isParent: false)
            changeRoot(tab)
        }
    }

    private func changeRoot(_ vc: UIViewController) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(vc)
        }
    }
}
