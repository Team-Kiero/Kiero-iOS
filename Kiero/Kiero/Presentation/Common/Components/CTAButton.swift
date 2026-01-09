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
        case gray
        
        var backgroundColor: UIColor {
            switch self {
            case .main: return .main
            case .gray: return .gray900
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .main: return .kBlack
            case .gray: return .white
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
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        addSubviews(contentStackView)
        contentStackView.addArrangedSubviews(iconImageView, mainLabel)
        
        self.snp.makeConstraints {
            $0.height.equalTo(50)
        }
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
    
    private func applyStyle() {
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
