import UIKit
import SnapKit
import Then

extension UIViewController {
    func showLogoutDialog(onConfirm: @escaping () -> Void) {
        let dimmedView = UIView().then {
            $0.backgroundColor = UIColor.kBlack.withAlphaComponent(0.75)
            $0.alpha = 1
        }
        
        let dialogBox = DialogBox().then {
            $0.configure(state: .logout)
            $0.alpha = 1
        }
        
        view.addSubviews(dimmedView, dialogBox)
        
        dimmedView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        dialogBox.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        dialogBox.onTapCancel = { [weak self] in
            self?.dismissDialog(dimmedView, dialogBox)
        }
        
        dialogBox.onTapConfirm = { [weak self] in
            self?.dismissDialog(dimmedView, dialogBox)
            onConfirm()
        }
    }
    
    func navigateToPickRole() {
        let roleSelectionVC = PickRoleViewController(viewModel: PickRoleViewModel(), diContainer: AppDIContainer.shared)
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
