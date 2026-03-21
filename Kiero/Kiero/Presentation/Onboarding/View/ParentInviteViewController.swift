//
//  ParentInviteViewController.swift
//  Kiero
//
//  Created by 안치욱 on 1/16/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class ParentInviteViewController: BaseViewController<ParentInviteViewModel> {
    
    private var isChildJoined = false
    private var isChecking = false

    private let profileBox = ProfileBox(name: "사용자", profileURL: "")
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.numberOfLines = 0
    }
    
    private let textField = TextField(type: .parent(.totalName))
    
    private let inviteView = InviteCodeView()
    
    private let startButton = CTAButton(enabledStyle: .main, disabledStyle: .gray900, size: .h49).then {
        $0.configure(title: "시작하기")
        $0.isEnabled = false
    }
    
    override func setStyle() {
        titleLabel.setTypo(.title2_20_SB, text: "아직 연결된 자녀 계정이 없어요\n자녀를 추가해주세요!")
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
        
        profileBox.onTap = { [weak self] in
            self?.showLogoutDialog {
                LogoutHelper.logoutToPickRole()
            }
        }
    }
    
    override func bind(viewModel: ParentInviteViewModel) {
        super.bind(viewModel: viewModel)

        profileBox.configure(
            name: TokenManager.shared.getUserName() ?? "",
            url: TokenManager.shared.getProfile() ?? ""
        )
        
        textField.setText(text: viewModel.childName)
        textField.isEditable = false
        
        Publishers.CombineLatest3(viewModel.inviteCode, viewModel.remainingText, viewModel.isExpired)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] code, time, expired in
                guard let self else { return }
                
                self.inviteView.configure(
                    code: code,
                    remainingTime: time,
                    isExpired: expired
                )
                
                let enabled = (!expired) && self.isChildJoined
                self.startButton.isEnabled = enabled
                self.startButton.alpha = enabled ? 1.0 : 0.5
            }
            .store(in: &cancellables)
        
        viewModel.inviteCode
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.isChildJoined = false
                self.startButton.isEnabled = false
                self.startButton.alpha = 0.5
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: .didReceiveSseEvent)
            .compactMap { $0.object as? SseEventPayload }
            .filter { $0.eventType == "CHILD_JOINED" }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.isChildJoined = true
                
                let expired = viewModel.isExpiredValue
                let enabled = (!expired) && self.isChildJoined
                self.startButton.isEnabled = enabled
                self.startButton.alpha = enabled ? 1.0 : 0.5
            }
            .store(in: &cancellables)
        
        viewModel.expiredEvent
            .receive(on: DispatchQueue.main)
            .sink {
                Toast.show(message: "초대코드가 만료되었습니다.", bottomInset: 83)
            }
            .store(in: &cancellables)
        
        inviteView.refreshDidTap = { [weak viewModel] in
            viewModel?.reissueInviteCode()
        }
    }
    
    @objc
    private func startButtonDidTap() {
        navigateToParentTap()
    }
    
    private func checkConnectionOnce() {
        guard !isChecking else { return }
        guard let viewModel else { return }
        guard viewModel.isExpiredValue == false else { return }
        guard isChildJoined == false else { return }
        
        isChecking = true
        Task { [weak self] in
            defer { self?.isChecking = false }
            do {
                let data: ChildRegistrationStatusDTO = try await BaseService.shared.request(
                    endPoint: .checkConnection(
                        lastName: viewModel.childLastName,
                        firstName: viewModel.childFirstName
                    )
                )
                if data.isRegistered {
                    await MainActor.run {
                        self?.isChildJoined = true
                        self?.startButton.isEnabled = true
                        self?.startButton.alpha = 1.0
                    }
                }
            } catch {
                // 조용히 무시(폴백이니까)
            }
        }
    }
    
    private func navigateToParentTap() {
        let tab = TabBarViewController(factory: AppDIContainer.shared, isParent: true)
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.changeRootViewController(tab)
        }
    }
}
