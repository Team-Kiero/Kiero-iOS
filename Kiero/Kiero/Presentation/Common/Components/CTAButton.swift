//
//  CTAButton.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/8/26.
//

import UIKit

import SnapKit
import Then

final class CTAButton: UIButton {
    enum Style {
        case main
        case gray900
        case gray800
        case gray100
        case black
        
        var backgroundColor: UIColor {
            switch self {
            case .main: return .main
            case .gray900: return .gray900
            case .gray800: return .gray800
            case .gray100: return .gray100
            case .black: return .kBlack
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .main: return .kBlack
            case .gray900: return .white
            case .gray800: return .white
            case .gray100: return .kBlack
            case .black: return .white
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.12, delay: 0, options: [.allowUserInteraction, .curveEaseOut]) {
                self.alpha = self.isHighlighted ? 0.5 : 1.0
            }
        }
    }
    
    private let style: Style
    
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
        $0.distribution = .fill
        $0.isUserInteractionEnabled = false
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let mainLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    init(style: Style) {
        self.style = style
        super.init(frame: .zero)
        setUI()
        setLayout()
        setStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        addSubviews(contentStackView)
        contentStackView.addArrangedSubviews(iconImageView, mainLabel)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(49)
        }
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
    
    private func setStyle() {
        self.backgroundColor = style.backgroundColor
        self.mainLabel.textColor = style.titleColor
        self.iconImageView.tintColor = style.titleColor
    }
    
    // MARK: - Configuration
    
    func configure(title: String, icon: UIImage? = nil) {
        mainLabel.setTypo(.title3_16_SB, text: title)
        
        if let icon = icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
}

