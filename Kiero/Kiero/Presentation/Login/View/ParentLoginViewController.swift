//
//  ParentLoginViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class ParentLoginViewController: BaseViewController<ParentLoginViewModel> {
    
    // MARK: - Properties
    
    private let kakaoTap = PassthroughSubject<Void, Never>()
    private let appleTap = PassthroughSubject<Void, Never>()
    
    private var loadingVC: UIViewController?
    
    // MARK: - UI Components
    
    private let parentNaviBar = NavigationBar(type: .back(title: "부모님으로 시작하기"))
    
    private let parentBubble = SpeechBubble(speech: "반가워요!")
    
    private let parentImageView = UIImageView().then {
        $0.image = .imgGoblinParent.resized(to: CGSize(width: 572, height: 572))
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    private let kakaoLoginButton = LoginButton(type: .kakao)
    private let appleLoginButton = LoginButton(type: .apple)
    
    override func setStyle() {
        parentImageView.transform = CGAffineTransform(rotationAngle: -(.pi / 180 * 35))
    }
    
    override func setUI() {
        view.addSubviews(
            parentNaviBar,
            parentBubble,
            parentImageView,
            kakaoLoginButton,
            appleLoginButton
        )
    }
    
    override func setLayout() {
        parentNaviBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(54)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(37)
        }
        
        parentBubble.snp.makeConstraints {
            $0.top.equalTo(parentNaviBar.snp.bottom).offset(131)
            $0.trailing.equalTo(parentImageView.snp.trailing).inset(378)
        }
        
        parentImageView.snp.makeConstraints {
            $0.top.equalTo(parentNaviBar.snp.bottom).offset(3)
            $0.trailing.equalToSuperview().offset(190)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(appleLoginButton.snp.top).offset(-8)
            $0.height.equalTo(49)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(17)
            $0.height.equalTo(49)
        }
    }
    
    override func addTarget() {
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        appleLoginButton.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        parentNaviBar.leftButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    override func bind(viewModel: ParentLoginViewModel) {
        super.bind(viewModel: viewModel)
        
        let output = viewModel.transform(
            input: .init(
                kakaoButtonTapped: kakaoTap.eraseToAnyPublisher(),
                appleButtonTapped: appleTap.eraseToAnyPublisher()
            )
        )
        
        output.state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                
                switch state {
                case .idle:
                    self.kakaoLoginButton.isEnabled = true
                    
                case .loading:
                    self.kakaoLoginButton.isEnabled = false
                    
                case .failure(let message):
                    self.kakaoLoginButton.isEnabled = true
                    Toast.show(message: message, bottomInset: 83)
                }
            }
            .store(in: &cancellables)
        
        output.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }
                self.handle(by: route)
            }
            .store(in: &cancellables)
    }
    
    private func navigateToParentOnboarding() {
        let vm = ParentOnboardingViewModel()
        let onboardingVC = UINavigationController(rootViewController: ParentOnboardingViewController(viewModel: vm, diContainer: AppDIContainer.shared))
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(onboardingVC)
        }
    }
    
    private func presentRequiredTermsBottomSheet(_ terms: [RequiredTerm]) {
        let serviceTermsURL = terms.first { $0.termsType == .serviceTerms }?.url
        let privacyPolicyURL = terms.first { $0.termsType == .privacyPolicy }?.url
        
        let termsBottomSheetVC = RequiredTermsBottomSheetWrapperViewController(
            serviceTermsURL: serviceTermsURL,
            privacyPolicyURL: privacyPolicyURL,
            onConfirm: { [weak self] in
                self?.navigateToParentOnboarding()
            }
        )
        
        termsBottomSheetVC.modalPresentationStyle = .overFullScreen
        termsBottomSheetVC.view.backgroundColor = .clear
        
        present(termsBottomSheetVC, animated: true)
    }
    
    private func handle(by route: LoginRoute) {
        switch route {
        case .parentOnboarding:
            let onboardingVC = AppDIContainer.shared.makeParentOnboardingViewController()
            if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
                sceneDelegate.changeRootViewController(onboardingVC)
            }
        case .parentTab:
            let tab = TabBarViewController(factory: AppDIContainer.shared, isParent: true)
            changeRoot(tab)
        case .requiredTerms(let terms):
            TokenManager.shared.saveRequiredTermsIds(terms.map { $0.termsId })
            presentRequiredTermsBottomSheet(terms)
        case let .toast(message):
            Toast.show(message: message, bottomInset: 83)
        }
    }
    
    private func changeRoot(_ vc: UIViewController) {
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(vc)
        }
    }
    
    @objc
    private func kakaoLoginButtonTapped() {
        view.endEditing(true)
        kakaoTap.send(())
    }
    
    @objc
    private func appleLoginButtonTapped() {
        appleTap.send(())
    }
}
