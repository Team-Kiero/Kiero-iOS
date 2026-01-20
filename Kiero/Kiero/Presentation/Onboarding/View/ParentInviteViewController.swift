//
//  ParentInviteViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class ParentInviteViewController: BaseViewController<BaseViewModel> {
    
    // MARK: - UI Components
    
    private let profileBox = ProfileBox(name: "스꾸삐", profileURL: "https://k.kakaocdn.net/dn/Aw6ap/dJMcafehtYl/o4UxbOofgNw3FQtDW5VUOk/img_640x640.jpg")
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private let textField = TextField(type: .parent(.totalName))
    
    private let inviteView = InviteCodeView()
    
    private let startButton = CTAButton(style: .gray900).then {
        $0.configure(title: "시작하기")
    }
    
    override func setStyle() {
        titleLabel.setTypo(.title2_20_SB, text: "아직 연결된 자녀 계정이 없어요\n자녀를 추가해주세요!")
        textField.setText(text: "꾸비")
    }
    
    override func setUI() {
        view.addSubviews(
            profileBox,
            titleLabel,
            textField,
            inviteView,
            startButton
        )
    }
    
    override func setLayout() {
        profileBox.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
            $0.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(profileBox.snp.bottom).offset(18)
            $0.leading.equalToSuperview().inset(16)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(14)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        inviteView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(5)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(266)
        }
        
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(17)
        }
    }
    
    override func addTarget() {
        startButton.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
    }
    
    private func navigateToParentTap() {
        let nav = UINavigationController(rootViewController: TabBarViewController(factory: AppDIContainer.shared, isParent: true))
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav)
        }
    }
    
    @objc
    private func startButtonDidTap() {
        navigateToParentTap()
    }
}
