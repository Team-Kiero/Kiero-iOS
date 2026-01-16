//
//  ChildLoginViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class ChildLoginViewController: BaseViewController<BaseViewModel> {
    
    // MARK: - UI Components
    
    private let childNaviBar = NavigationBar(type: .back(title: "자녀로 시작하기"))
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray200
    }
    
    private let lastNameTextField = TextField(type: .child(.lastName))
    
    private let firstNameTextField = TextField(type: .child(.firstName))
    
    private let codeTextField = TextField(type: .child(.inviteCode))
    
    private let startButton = CTAButton(style: .main).then {
        $0.configure(title: "여정 시작하기")
    }
    
    override func setUI() {
        view.addSubviews(
            childNaviBar,
            titleLabel,
            lastNameTextField,
            firstNameTextField,
            codeTextField,
            startButton
        )
    }
    
    override func setLayout() {
        childNaviBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(childNaviBar.snp.bottom).offset(21)
            $0.leading.equalToSuperview().inset(16)
        }
        
        lastNameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(31)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        firstNameTextField.snp.makeConstraints {
            $0.top.equalTo(lastNameTextField.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(firstNameTextField.snp.bottom).offset(35)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-17)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
}
