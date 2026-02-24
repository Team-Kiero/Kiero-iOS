//
//  ParentOnboardingViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/15/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class ParentOnboardingViewController: BaseViewController<ParentOnboardingViewModel> {
    
    // MARK: - Properties
    
    private var isLastValid = false
    private var isFirstValid = false
    private let userName = TokenManager.shared.getUserName() ?? ""
    private let profileURL = TokenManager.shared.getProfile() ?? ""
    
    // MARK: - UI Components
    
    private let profileBox = ProfileBox(name: "사용자", profileURL: "")
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private let lastNameTextField = TextField(type: .parent(.lastName))
    private let firstNameTextField = TextField(type: .parent(.firstName))
    
    private let generateButton = CTAButton(enabledStyle: .main, disabledStyle: .gray900, size: .large).then {
        $0.configure(title: "초대코드 생성")
        $0.isEnabled = false
    }
    
    // MARK: - Life Cycle
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
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
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        firstNameTextField.snp.makeConstraints {
            $0.top.equalTo(lastNameTextField.snp.bottom).offset(18)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(91)
        }
        
        generateButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(17)
        }
    }
    
    override func addTarget() {
        generateButton.addTarget(self, action: #selector(generateButtonDidTap), for: .touchUpInside)
        
        lastNameTextField.innerTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        firstNameTextField.innerTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        
        profileBox.onTap = {
            self.showLogoutDialog {
                self.viewModel?.logout()
            }
        }
    }
    
    override func setDelegate() {
        lastNameTextField.externalDelegate = self
        firstNameTextField.externalDelegate = self
    }
    
    override func bind(viewModel: ParentOnboardingViewModel) {
        super.bind(viewModel: viewModel)
        
        profileBox.configure(
            name: TokenManager.shared.getUserName() ?? "",
            url: TokenManager.shared.getProfile() ?? ""
        )
        
        lastNameTextField.onValidationChanged = { [weak self] isValid in
            self?.isLastValid = isValid
            self?.updateGenerateButton()
        }
        
        firstNameTextField.onValidationChanged = { [weak self] isValid in
            self?.isFirstValid = isValid
            self?.updateGenerateButton()
        }
        
        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }
                print("✅ [VC] route received:", route)
                print("nav:", self.navigationController as Any)
                switch route {
                case .invite(let last, let first, let inviteCode, let issuedAt):
                    self.navigateToInviteView(childLastName: last,
                                              childFirstName: first,
                                              inviteCode: inviteCode,
                                              issuedAt: issuedAt)
                case .logout:
                    LogoutHelper.logoutToPickRole()
                }
            }
            .store(in: &cancellables)
        
        viewModel.isGenerateEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.generateButton.isEnabled = enabled
            }
            .store(in: &cancellables)
        
        textDidChange()
    }
    
    @objc
    private func generateButtonDidTap() {
        let last = lastNameTextField.innerTextField.text ?? ""
        let first = firstNameTextField.innerTextField.text ?? ""
        viewModel?.generateInviteCode(childLastName: last, childFirstName: first)
    }
    
    @objc
    private func textDidChange() {
        viewModel?.lastName.send(lastNameTextField.innerTextField.text ?? "")
        viewModel?.firstName.send(firstNameTextField.innerTextField.text ?? "")
    }
    
    private func updateGenerateButton() {
        let enabled = isLastValid && isFirstValid
        generateButton.isEnabled = enabled
    }
    
    private func navigateToInviteView(
        childLastName: String,
        childFirstName: String,
        inviteCode: String,
        issuedAt: Date
    ) {
        let vm = ParentInviteViewModel(
            childLastName: childLastName,
            childFirstName: childFirstName,
            inviteCode: inviteCode,
            issuedAt: issuedAt
        )
        
        let vc = ParentInviteViewController(viewModel: vm, diContainer: AppDIContainer.shared)
        let nav = UINavigationController(rootViewController: vc)
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(nav)
        }
    }
}

extension ParentOnboardingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === lastNameTextField.innerTextField {
            firstNameTextField.innerTextField.becomeFirstResponder()
        } else if textField === firstNameTextField.innerTextField {
            textField.resignFirstResponder()
        }
        return true
    }
}
