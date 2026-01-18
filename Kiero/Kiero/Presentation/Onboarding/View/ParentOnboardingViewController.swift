//
//  ParentOnboardingViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import UIKit

final class ParentOnboardingViewController: BaseViewController<ParentOnboardingViewModel> {
    
    // MARK: - UI Components
    
    private let profileBox = ProfileBox(name: "스꾸삐", profileURL: "")
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private let lastNameTextField = TextField(type: .parent(.lastName))
    
    private let firstNameTextField = TextField(type: .parent(.firstName))
    
    private let generateButton = CTAButton(style: .main).then {
        $0.configure(title: "초대코드 생성")
    }
   
    override func setStyle() {
        titleLabel.setTypo(.title2_20_SB, text: "아직 연결된 자녀 계정이 없어요\n자녀를 추가해주세요!")
    }
    
    override func setUI() {
        view.addSubviews(
            profileBox,
            titleLabel,
            lastNameTextField,
            firstNameTextField,
            generateButton
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
        
        lastNameTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        firstNameTextField.snp.makeConstraints {
            $0.top.equalTo(lastNameTextField.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        generateButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(41)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    override func bind(viewModel: ParentOnboardingViewModel) {
        super.bind(viewModel: viewModel)
        profileBox.configure(name: viewModel.name, url: viewModel.profileURL)
    }
}
