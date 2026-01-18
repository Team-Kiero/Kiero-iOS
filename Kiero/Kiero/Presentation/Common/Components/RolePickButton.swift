//
//  RolePickButton.swift
//  Kiero
//
//  Created by 안치욱 on 1/13/26.
//

import UIKit

import SnapKit
import Then

enum LoginUser {
    case parent
    case child
}

extension LoginUser {
    var buttonIcon: UIImage {
        switch self {
        case .parent:
            return .imgGoblinGlass
        case .child:
            return .imgGoblinSmile
        }
    }
    
    var buttonTitle: String {
        switch self {
        case .parent:
            return "부모님으로 시작하기"
        case .child:
            return "자녀로 시작하기"
        }
    }
}

final class RolePickButton: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let buttonImageView = UIImageView().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let buttonLabel = UILabel().then {
        $0.textAlignment = .center
        $0.isUserInteractionEnabled = true
    }
    
    // MARK: - Life Cycle
    
    init(type: LoginUser) {
        super.init(frame: .zero)
        setStyle()
        setUI()
        setLayout()
        setAction()
        configure(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting Methods
    
    private func setStyle() {
        backgroundColor = .gray900
        layer.cornerRadius = 10
    }
    
    private func setUI() {
        addSubviews(
            buttonImageView,
            buttonLabel
        )
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(80)
        }
        
        buttonImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(29)
        }
        
        buttonLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(20)
        }
    }
    
    private func setAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(loginButtonDidTap))
        addGestureRecognizer(tap)
    }
    
    private func configure(type: LoginUser) {
        switch type {
            case .parent:
            buttonImageView.image = type.buttonIcon.resized(to: CGSize(width: 52, height: 48))
            buttonLabel.setTypo(.body2_16_R, text: type.buttonTitle)
        case .child:
            buttonImageView.image = type.buttonIcon.resized(to: CGSize(width: 49, height: 52))
            buttonLabel.setTypo(.body2_16_R, text: type.buttonTitle)
        }
        buttonLabel.textAlignment = .center
        buttonLabel.textColor = .white
    }
    
    @objc
    private func loginButtonDidTap() {
        UIView.animate(withDuration: 0.12,
                       animations: {
            self.alpha = 0.5
        },
                       completion: { _ in
            self.alpha = 1.0
            self.onTap?()
        })
    }
}
