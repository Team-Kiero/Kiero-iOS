//
//  ChildrenLoginViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class ChildrenLoginViewController: BaseViewController<BaseViewModel> {
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func setStyle() {
        titleLabel.setTypo(.title3_16_SB, text: "이름과 부모님께 받은 초대 코드를 입력해줘!")
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
            $0.top.equalToSuperview().offset(54)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
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
            $0.top.equalTo(firstNameTextField.snp.bottom).offset(30)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        startButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-17)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    override func addTarget() {
        startButton.addTarget(self, action: #selector(startButtonDidTap), for: .touchUpInside)
        childNaviBar.leftButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    override func setDelegate() {
        firstNameTextField.externalDelegate = self
        lastNameTextField.externalDelegate = self
        codeTextField.externalDelegate = self
    }
    
    private func navigateToChildOnboarding() {
        let vc = AppDIContainer.shared.makeChildOnboardingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func startButtonDidTap() {
        navigateToChildOnboarding()
    }
}

extension ChildrenLoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === lastNameTextField.innerTextField{
            firstNameTextField.innerTextField.becomeFirstResponder()
        }
        else if textField === firstNameTextField.innerTextField{
            codeTextField.innerTextField.becomeFirstResponder()
        }
        else if textField === codeTextField.innerTextField{
            textField.resignFirstResponder()
        }
        return true
    }
}
