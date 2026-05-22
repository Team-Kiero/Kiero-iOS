//
//  RewardCoordinator.swift
//  Kiero
//
//  Created by 안치욱 on 5/20/26.
//

import SwiftUI
import UIKit

final class RewardCoordinator: Coordinator {
    
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
        let vc = factory.makeRewardViewController()
        
        vc.onAddRewardTap = { [weak self, weak vc] in
            guard let self, let vc else { return }
            self.showAddReward(from: vc)
        }
        
        vc.onEditRewardTap = { [weak self, weak vc] reward in
            guard let self, let vc else { return }
            self.showEditReward(from: vc, reward: reward)
        }
        
        return vc
    }
    
    private func showAddReward(from viewController: RewardHostingController) {
        let editView = RewardEditView(
            mode: .add,
            onSave: { [weak viewController] title, cost in
                viewController?.viewModel.addReward(title: title, cost: cost)
                
                NotificationCenter.default.post(name: .hideTabBar, object: false)
                NotificationCenter.default.post(name: .hideNavigationBar, object: false)
            },
            onClose: {
                NotificationCenter.default.post(name: .hideTabBar, object: false)
                NotificationCenter.default.post(name: .hideNavigationBar, object: false)
            }
        )
        
        let vc = UIHostingController(rootView: editView)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
    
    private func showEditReward(
        from viewController: RewardHostingController,
        reward: Reward
    ) {
        let editView = RewardEditView(
            mode: .edit(reward),
            onSave: { [weak viewController] title, cost in
                viewController?.viewModel.updateReward(
                    id: reward.id,
                    title: title,
                    cost: cost
                )
                
                NotificationCenter.default.post(name: .hideTabBar, object: false)
                NotificationCenter.default.post(name: .hideNavigationBar, object: false)
            },
            onClose: {
                NotificationCenter.default.post(name: .hideTabBar, object: false)
                NotificationCenter.default.post(name: .hideNavigationBar, object: false)
            }
        )
        
        let vc = UIHostingController(rootView: editView)
        
        NotificationCenter.default.post(name: .hideTabBar, object: true)
        NotificationCenter.default.post(name: .hideNavigationBar, object: true)
        
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true)
    }
}
