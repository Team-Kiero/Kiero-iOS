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
        case main, gray900, gray800, gray100, black
        
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
            case .gray900, .gray800, .black: return .white
            case .gray100: return .gray900
            }
        }
    }
    
    enum Size {
        case large
        case medium
        case small
        
        var height: CGFloat {
            switch self {
            case .large: return 49
            case .medium: return 45
            case .small: return 40
            }
        }
        
        var typo: UIFont.NotoSans {
            switch self {
            case .large, .medium: return .title3_16_SB
            case .small: return .title4_14_SB
            }
        }
    }
    
    // MARK: - Properties
    
    private var currentStyle: Style
    private var currentSize: Size
    
    private var enabledStyle: Style?
    private var disabledStyle: Style?
    
    // MARK: - UI Components
    
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
        
    init(style: Style, size: Size) {
        self.currentStyle = style
        self.currentSize = size
        super.init(frame: .zero)
        
        setUI()
        setLayout()
        updateStyle()
    }
    
    convenience init(enabledStyle: Style, disabledStyle: Style, size: Size) {
        self.init(style: enabledStyle, size: size)
        self.enabledStyle = enabledStyle
        self.disabledStyle = disabledStyle
        self.isEnabled = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                self.currentStyle = isEnabled ? enabledStyle : disabledStyle
                updateStyle()
            } else {
                self.alpha = isEnabled ? 1.0 : 0.4
            }
        }
    }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        self.addSubview(contentStackView)
        contentStackView.addArrangedSubviews(iconImageView, mainLabel)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(currentSize.height)
        }
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
    
    private func updateStyle() {
        self.backgroundColor = currentStyle.backgroundColor
        self.mainLabel.textColor = currentStyle.titleColor
        self.iconImageView.tintColor = currentStyle.titleColor
        self.mainLabel.font = currentSize.typo.font
    }
        
    func configure(title: String, icon: UIImage? = nil) {
        mainLabel.setTypo(currentSize.typo, text: title)
        
        if let icon = icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
}
