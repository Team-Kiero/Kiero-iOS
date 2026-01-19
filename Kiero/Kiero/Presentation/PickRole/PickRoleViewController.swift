//
//  PickRoleViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class PickRoleViewController: BaseViewController<BaseViewModel> {
    
    private let logoImageView = UIImageView().then {
        $0.image = .imgLogo
        $0.contentMode = .scaleAspectFit
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .schedule1
        $0.textAlignment = .center
    }
    
    private let parentButton = RolePickButton(type: .parent)
    
    private let childButton = RolePickButton(type: .child)
    
    override func setStyle() {
        descriptionLabel.setTypo(.body1_18_R, text: "아이의 하루가 모험이 되는 곳")
    }
    
    override func setUI() {
        view.addSubviews(
            logoImageView,
            descriptionLabel,
            parentButton,
            childButton
        )
    }
    
    override func setLayout() {
        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(12)
            $0.width.equalTo(300)
            $0.height.equalTo(63)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(-22)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(189)
        }
        
        childButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-78)
        }
        
        parentButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(childButton.snp.top).offset(-25)
        }
    }
    
    override func addTarget() {
        parentButton.onTap = {
            self.navigateToParentLogin()
        }
        
        childButton.onTap = {
            self.navigateToChildrenLogin()
        }
    }
    
    private func navigateToParentLogin() {
        let repo = AppDIContainer.shared.makeAuthRepository()

        let vm = ParentLoginViewModel(repo: repo)

        let vc = ParentLoginViewController(viewModel: vm, diContainer: AppDIContainer.shared)

        if let nav = navigationController {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    private func navigateToChildrenLogin() {
        let vc = ChildrenLoginViewController(viewModel: BaseViewModel(), diContainer: AppDIContainer.shared)
        navigationController?.pushViewController(vc, animated: true)
        print("nav:", navigationController as Any)
    }
}
