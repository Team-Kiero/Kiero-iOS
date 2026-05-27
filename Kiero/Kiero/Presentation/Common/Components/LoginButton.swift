//
//  LoginButton.swift
//  Kiero
//
//  Created by 신혜연 on 5/18/26.
//

import UIKit

import SnapKit
import Then

enum LoginButtonType {
    case kakao
    case apple
}

final class LoginButton: UIButton {
    
    // MARK: - UI Components
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let loginTitleLabel = UILabel()
    
    // MARK: - Life Cycle
    
    init(type: LoginButtonType) {
        super.init(frame: .zero)
        
        setStyle(type: type)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle(type: LoginButtonType) {
        layer.cornerRadius = 10
        clipsToBounds = true
        
        switch type {
        case .kakao:
            backgroundColor = .kakaoYellow
            iconImageView.image = UIImage(resource: .kakaoLogo)
            loginTitleLabel.setTypo(.title3_16_SB, text: "카카오톡 로그인")
            loginTitleLabel.textColor = .kBlack
        case .apple:
            backgroundColor = .white
            iconImageView.image = UIImage(resource: .appleLogo)
            loginTitleLabel.setTypo(.title3_16_SB, text: "Apple로 로그인")
            loginTitleLabel.textColor = .kBlack
        }
    }
    
    private func setUI() {
        addSubviews(iconImageView, loginTitleLabel)
    }
    
    private func setLayout() {
        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(41)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        
        loginTitleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
