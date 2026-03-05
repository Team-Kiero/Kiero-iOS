//
//  PickRoleView.swift
//  Kiero
//
//  Created by 안치욱 on 3/3/26.
//

import UIKit

import SnapKit
import Then

final class PickRoleView: UIView {

    // MARK: - Callbacks

    var onRoleChanged: ((LoginUser?) -> Void)?
    var onTapStart: ((LoginUser) -> Void)?

    // MARK: - State
    
    private(set) var selectedRole: LoginUser? {
        didSet {
            updateSelectionUI()
            onRoleChanged?(selectedRole)
        }
    }

    // MARK: - UI
    
    private let containerView = UIView().then {
        $0.backgroundColor = .clear
    }

    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = .gray200
        $0.setTypo(.title3_16_SB, text: "어떤 사용자가 사용하시나요?")
    }

    private let roleStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 12
    }

    let parentButton = RolePickButton(type: .parent)
    let childButton  = RolePickButton(type: .child)

    private let startButton = CTAButton(enabledStyle: .main, disabledStyle: .gray900).then {
        $0.configure(title: "시작하기")
        $0.isEnabled = false
    }

    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
        bindActions()
        updateSelectionUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    
    private func setUI() {
        addSubview(containerView)
        containerView.addSubviews(titleLabel, roleStackView, startButton)
        roleStackView.addArrangedSubviews(parentButton, childButton)
    }

    private func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }

        roleStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(17)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(81)
        }

        startButton.snp.makeConstraints {
            $0.top.equalTo(roleStackView.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(17)
            $0.height.equalTo(49)
        }
    }

    private func bindActions() {
        parentButton.onTap = { [weak self] in
            self?.select(role: .parent)
        }
        childButton.onTap = { [weak self] in
            self?.select(role: .child)
        }
        startButton.addTarget(self, action: #selector(didTapStart), for: .touchUpInside)
    }

    // MARK: - Logic
    
    private func select(role: LoginUser) {
        selectedRole = role
    }

    @objc private func didTapStart() {
        guard let role = selectedRole else { return }
        onTapStart?(role)
    }

    private func updateSelectionUI() {
        let isParentPicked = (selectedRole == .parent)
        let isChildPicked  = (selectedRole == .child)

        parentButton.setPicked(isParentPicked)
        childButton.setPicked(isChildPicked)

        let enabled = (selectedRole != nil)
        startButton.isEnabled = enabled
    }
}
