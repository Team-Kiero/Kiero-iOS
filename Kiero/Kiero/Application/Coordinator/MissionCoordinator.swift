//
//  MissionCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import UIKit

final class MissionCoordinator: Coordinator {
    
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    
    private var childCoordinators: [any Coordinator] = []
    
    init(
        navigationController: UINavigationController,
        factory: ViewControllerFactory
    ) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() -> UIViewController {
        let vc = factory.makeMissionViewController()
        
        vc.onAddMissionDirectlyTap = { [weak self, weak vc] in
            guard let self, let vc else { return }
            self.showWriteMission(from: vc)
        }
        
        vc.onAddMissionByAITap = { [weak self, weak vc] in
            guard let self, let vc else { return }
            self.showAIMission(from: vc)
        }
        
        vc.onEditMissionTap = { [weak self, weak vc] mission, dueAt, bottomSheet in
            guard let self, let vc else { return }
            self.showEditMission(
                from: vc,
                mission: mission,
                dueAt: dueAt,
                bottomSheet: bottomSheet
            )
        }
        
        return vc
    }
    
    private func showWriteMission(from viewController: UIViewController) {
        let vc = factory.makeWriteMissionViewController()
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    private func showAIMission(from viewController: UIViewController) {
        let coordinator = AIMissionCoordinator(
            presentingViewController: viewController,
            factory: factory
        )
        
        childCoordinators.append(coordinator)
        
        let vc = coordinator.start()
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    private func showEditMission(
        from viewController: UIViewController,
        mission: MissionItemDTO,
        dueAt: String,
        bottomSheet: DetailBottomSheet
    ) {
        let editVC = factory.makeWriteMissionViewController()
        editVC.configureEditMode(with: mission, dueAt: dueAt)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        
        editVC.modalPresentationStyle = .fullScreen
        
        bottomSheet.dismiss(animated: false) {
            viewController.present(editVC, animated: true)
        }
    }
}
