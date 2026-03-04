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
    var unselectedIcon: UIImage {
        return .btnUncheck
    }
    
    var selectedIcon: UIImage {
        return .btnCheckWhite
    }
    
    var buttonTitle: String {
        switch self {
        case .parent:
            return "부모님으로"
        case .child:
            return "자녀로"
        }
    }
}

final class RolePickButton: UIView {

    // MARK: - Public
    
    var onTap: (() -> Void)?

    func setPicked(_ picked: Bool) {
        isPicked = picked
    }

    var picked: Bool { isPicked }

    // MARK: - Private
    
    private let type: LoginUser
    private var isPicked: Bool = false {
        didSet { updateStyle() }
    }

    // MARK: - UI Components
    
    private let buttonImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isUserInteractionEnabled = false
    }

    private let buttonLabel = UILabel().then {
        $0.textAlignment = .center
        $0.isUserInteractionEnabled = false
    }

    // MARK: - Init
    
    init(type: LoginUser) {
        self.type = type
        super.init(frame: .zero)
        setUI()
        setLayout()
        setAction()
        configure()
        updateStyle()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    
    private func setUI() {
        layer.cornerRadius = 20
        clipsToBounds = true
        addSubviews(buttonImageView, buttonLabel)
    }

    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(81)
        }

        buttonImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(14)
            $0.size.equalTo(30)
        }

        buttonLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(buttonImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualToSuperview().inset(14)
        }
    }

    private func setAction() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(loginButtonDidTap))
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }

    private func configure() {
        buttonLabel.setTypo(.body2_16_R, text: type.buttonTitle)
        buttonLabel.textAlignment = .center
    }

    // MARK: - Style
    
    private func updateStyle() {
        buttonImageView.image = isPicked ? type.selectedIcon : type.unselectedIcon

        if isPicked {
            backgroundColor = .gray900
            layer.borderWidth = 1
            layer.borderColor = UIColor.white.cgColor
            buttonLabel.textColor = .white
        } else {
            backgroundColor = .gray900
            layer.borderWidth = 0
            layer.borderColor = nil
            buttonLabel.textColor = .white.withAlphaComponent(0.9)
        }
    }

    // MARK: - Tap
    
    @objc
    private func loginButtonDidTap() {
        UIView.animate(withDuration: 0.08,
                       animations: {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }, completion: { _ in
            UIView.animate(withDuration: 0.08) {
                self.transform = .identity
            }
            self.onTap?()
        })
    }
}
