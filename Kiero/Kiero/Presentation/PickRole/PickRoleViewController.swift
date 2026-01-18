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
    
    //private let viewModel: PickRoleViewModelType
    
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
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(186)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(10)
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
            
        }
        
        childButton.onTap = {
            
        }
    }
}

#Preview {
    PickRoleViewController(viewModel: PickRoleViewModel(), diContainer: AppDIContainer.shared)
}
