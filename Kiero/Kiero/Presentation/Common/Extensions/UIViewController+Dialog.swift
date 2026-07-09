import UIKit
import SnapKit
import Then

extension UIViewController {
    func showLogoutDialog(onConfirm: @escaping () -> Void) {
        let targetView: UIView = self.tabBarController?.view ?? self.navigationController?.view ?? self.view
        
        let dimmedView = UIView().then {
            $0.backgroundColor = UIColor.kBlack.withAlphaComponent(0.75)
            $0.alpha = 1
        }
        
        let dialogBox = DialogBox().then {
            $0.configure(state: .logout)
            $0.alpha = 1
        }
        
        targetView.addSubviews(dimmedView, dialogBox)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dialogBox.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        targetView.bringSubviewToFront(dimmedView)
        targetView.bringSubviewToFront(dialogBox)
        
        dialogBox.onTapCancel = { [weak self] in
            self?.dismissDialog(dimmedView, dialogBox)
        }
        
        dialogBox.onTapConfirm = { [weak self] in
            self?.dismissDialog(dimmedView, dialogBox)
            onConfirm()
        }
    }
    
    func navigateToPickRole() {
        let roleSelectionVC = AppDIContainer.shared.makePickRoleViewController() as! PickRoleViewController
        
        roleSelectionVC.onSelectParent = {
#if KIERO_PARENT
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            
            let nav = UINavigationController()
            sceneDelegate.changeRootViewController(nav, animated: true)
            
            let coordinator = ParentCoordinator(navigationController: nav, diContainer: AppDIContainer.shared)
            coordinator.onRequestRootChange = { [weak sceneDelegate] vc in
                sceneDelegate?.changeRootViewController(vc)
            }
            sceneDelegate.parentCoordinator = coordinator
            coordinator.showParentLogin()
#endif
        }
        
        roleSelectionVC.onSelectChild = {
#if KIERO_CHILD
            guard let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate else { return }
            
            let nav = UINavigationController()
            sceneDelegate.changeRootViewController(nav, animated: true)
            
            let coordinator = ChildCoordinator(navigationController: nav, diContainer: AppDIContainer.shared)
            coordinator.onRequestRootChange = { [weak sceneDelegate] vc in
                sceneDelegate?.changeRootViewController(vc)
            }
            sceneDelegate.childCoordinator = coordinator
            coordinator.start()
#endif
        }
        
        let nav = UINavigationController(rootViewController: roleSelectionVC)
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav, animated: true)
        }
    }
    
    func dismissDialog(_ dimmed: UIView, _ dialog: UIView) {
        dimmed.removeFromSuperview()
        dialog.removeFromSuperview()
    }
}
