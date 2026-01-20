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
    
    // MARK: - UI Components
    
    private let parentNaviBar = NavigationBar(type: .back(title: "부모님으로 시작하기"))
    
    private let parentBubble = SpeechBubble(speech: "반가워요!")
    
    private let parentImageView = UIImageView().then {
        $0.image = .imgGoblinParent.resized(to: CGSize(width: 572, height: 572))
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    
    private let kakaoLoginButton = UIButton().then {
        $0.setBackgroundImage(.btnKakao, for: .normal)
    }
    
    override func setStyle() {
        parentImageView.transform = CGAffineTransform(rotationAngle: -(.pi / 180 * 35))
    }
    
    override func setUI() {
        view.addSubviews(
            parentNaviBar,
            parentBubble,
            parentImageView,
            kakaoLoginButton
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(17)
        }
    }
    
    override func addTarget() {
        kakaoLoginButton.addTarget(self, action: #selector(kakaoLoginButtonTapped), for: .touchUpInside)
        parentNaviBar.leftButtonAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    override func bind(viewModel: ParentLoginViewModel) {
        super.bind(viewModel: viewModel)
        
        let output = viewModel.transform(
            input: .init(kakaoButtonTapped: kakaoTap.eraseToAnyPublisher())
        )
        
        output.route
            .receive(on: DispatchQueue.main)
            .sink { [weak self] route in
                guard let self else { return }
                switch route {
                case let .parentOnboarding(name, url):
                    self.navigateToParentOnboarding(name: name, url: url)
                case .childOnboarding:
                    self.kakaoLoginButtonTapped()
                }
            }
            .store(in: &cancellables)
    }
    
    @objc
    private func kakaoLoginButtonTapped() {
        kakaoTap.send(())
    }
    
    private func navigateToParentOnboarding(name: String, url: String) {
        let vm = ParentOnboardingViewModel(name: name, profileURL: url)
        let onboardingVC = UINavigationController(rootViewController: ParentOnboardingViewController(viewModel: vm, diContainer: AppDIContainer.shared))
        
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(onboardingVC)
        }
    }
}
