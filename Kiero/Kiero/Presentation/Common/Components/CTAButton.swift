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
        
        var buttonHeight: CGFloat {
            switch self {
            case .main, .gray900, .gray800:
                return 49
            case .black:
                return 45
            case .gray100:
                return 40
            }
        }
        
        var typo: UIFont.NotoSans {
            switch self {
            case .main, .gray900, .gray800, .black:
                return .title3_16_SB
            case .gray100:
                return .title4_14_SB
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
    
    override var isEnabled: Bool {
        didSet {
            if let enabledStyle, let disabledStyle {
                applyStyle(isEnabled ? enabledStyle : disabledStyle)
            } else {
                self.alpha = isEnabled ? 1.0 : 0.4
            }
        }
    }
    
    private var style: Style
    private var enabledStyle: Style?
    private var disabledStyle: Style?
    
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
        setLayout(height: style.buttonHeight)
        applyStyle(style)
    }
    
    convenience init(enabledStyle: Style, disabledStyle: Style) {
        self.init(style: enabledStyle)
        self.enabledStyle = enabledStyle
        self.disabledStyle = disabledStyle
        self.isEnabled = true
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
    
    private func setLayout(height: CGFloat) {
        self.snp.makeConstraints {
            $0.height.equalTo(height)
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
    
    private func applyStyle(_ style: Style) {
        self.style = style
        self.backgroundColor = style.backgroundColor
        self.mainLabel.textColor = style.titleColor
        self.iconImageView.tintColor = style.titleColor
        self.mainLabel.font = style.typo.font
    }
    
    // MARK: - Configuration
    
    func configure(title: String, icon: UIImage? = nil) {
        mainLabel.setTypo(style.typo, text: title)
        
        if let icon = icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
}

