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
    }

    override func setDelegate() {
        lastNameTextField.externalDelegate = self
        firstNameTextField.externalDelegate = self
    }

    override func bind(viewModel: ParentOnboardingViewModel) {
        super.bind(viewModel: viewModel)

        profileBox.configure(name: viewModel.name, url: viewModel.profileURL)

        viewModel.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (route: ParentOnboardingRoute) in
                guard let self else { return }
                switch route {
                case .invite(let childFullName, let inviteCode, let issue):
                    self.navigateToInviteView(childName: childFullName, inviteCode: inviteCode, issuedAt: issue)
                }
            }
            .store(in: &cancellables)

        // TODO: - state 구독해서 로딩/에러 UI 처리
        // viewModel.state.sink { ... }.store(in: &cancellables)
    }

    @objc
    private func generateButtonDidTap() {
        let last = lastNameTextField.innerTextField.text ?? ""
        let first = firstNameTextField.innerTextField.text ?? ""
        viewModel?.generateInviteCode(childLastName: last, childFirstName: first)
    }

    private func navigateToInviteView(childName: String, inviteCode: String, issuedAt: Date) {
        let vm = ParentInviteViewModel(
            parentName: viewModel?.name ?? "",
            profileURL: viewModel?.profileURL ?? "",
            childName: childName,
            inviteCode: inviteCode,
            issuedAt: issuedAt
        )
        let vc = ParentInviteViewController(viewModel: vm, diContainer: AppDIContainer.shared)
        navigationController?.pushViewController(vc, animated: true)
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

//final class ParentOnboardingViewController: BaseViewController<ParentOnboardingViewModel> {
//    
//    // MARK: - UI Components
//    
//    private let profileBox = ProfileBox(name: "스꾸삐", profileURL: "")
//    
//    private let titleLabel = UILabel().then {
//        $0.textColor = .white
//        $0.textAlignment = .left
//        $0.numberOfLines = 0
//    }
//    
//    private let lastNameTextField = TextField(type: .parent(.lastName))
//    
//    private let firstNameTextField = TextField(type: .parent(.firstName))
//    
//    private let generateButton = CTAButton(style: .main).then {
//        $0.configure(title: "초대코드 생성")
//    }
//    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.view.endEditing(true)
//    }
//   
//    override func setStyle() {
//        titleLabel.setTypo(.title2_20_SB, text: "아직 연결된 자녀 계정이 없어요\n자녀를 추가해주세요!")
//    }
//    
//    override func setUI() {
//        view.addSubviews(
//            profileBox,
//            titleLabel,
//            lastNameTextField,
//            firstNameTextField,
//            generateButton
//        )
//    }
//    
//    override func setLayout() {
//        profileBox.snp.makeConstraints {
//            $0.top.equalTo(view.safeAreaLayoutGuide).offset(15)
//            $0.trailing.equalToSuperview()
//        }
//        
//        titleLabel.snp.makeConstraints {
//            $0.top.equalTo(profileBox.snp.bottom).offset(18)
//            $0.leading.equalToSuperview().inset(16)
//        }
//        
//        lastNameTextField.snp.makeConstraints {
//            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
//            $0.horizontalEdges.equalToSuperview()
//            $0.height.equalTo(91)
//        }
//        
//        firstNameTextField.snp.makeConstraints {
//            $0.top.equalTo(lastNameTextField.snp.bottom).offset(18)
//            $0.horizontalEdges.equalToSuperview()
//            $0.height.equalTo(91)
//        }
//        
//        generateButton.snp.makeConstraints {
//            $0.horizontalEdges.equalToSuperview().inset(16)
//            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(17)
//        }
//    }
//    
//    override func addTarget() {
//        generateButton.addTarget(self, action: #selector(generateButtonDidTap), for: .touchUpInside)
//    }
//    
//    override func setDelegate() {
//        lastNameTextField.externalDelegate = self
//        firstNameTextField.externalDelegate = self
//    }
//    
//    override func bind(viewModel: ParentOnboardingViewModel) {
//        super.bind(viewModel: viewModel)
//        profileBox.configure(name: viewModel.name, url: viewModel.profileURL)
//    }
//    
//    @objc
//    private func generateButtonDidTap() {
//        navigateToInviteView()
//    }
//    
//    private func navigateToInviteView() {
//        let vc = ParentInviteViewController(viewModel: BaseViewModel(), diContainer: AppDIContainer.shared)
//        self.navigationController?.pushViewController(vc, animated: true)
//    }
//}
//
//extension ParentOnboardingViewController: UITextFieldDelegate {
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        if textField === lastNameTextField.innerTextField{
//            firstNameTextField.innerTextField.becomeFirstResponder()
//        }
//        else if textField === firstNameTextField.innerTextField{
//            textField.resignFirstResponder()
//        }
//        return true
//    }
//}
