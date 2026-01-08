//
//  KieroButton.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/8/26.
//

import UIKit
import SnapKit
import Then

final class KieroButton: UIButton {
    private let type: KieroButtonType
    private let color: KieroButtonColor
    
    private let contentStackView = UIStackView().then {
        $0.isUserInteractionEnabled = false
        $0.alignment = .center
        $0.distribution = .fill
    }
    
    private let mainLabel = UILabel().then {
        $0.setTypo(.title3_16_SB)
        $0.textAlignment = .center
    }
    
    //large용
    private let subLabel = UILabel().then {
        $0.setTypo(.body2_16_R)
        $0.textAlignment = .center
        $0.isHidden = true // 이걸 쓰는 이유?
    }
    
    // medium용
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    // MARK: - init
    
    init(type: KieroButtonType, color: KieroButtonColor){
        self.type = type
        self.color = color
        super.init(frame: .zero)
        setupUI()
        applyStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("에러입니다")
    }
    
    private func setupUI() {
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        addSubviews(contentStackView)
        
        switch type {
        case .medium:
            contentStackView.axis = .horizontal
            contentStackView.spacing = 10 // ?
            contentStackView.addArrangedSubview(iconImageView)
            contentStackView.addArrangedSubview(mainLabel)
            
            iconImageView.snp.makeConstraints {
                $0.size.equalTo(16)
            }
            
        case .large:
            contentStackView.axis = .vertical
            contentStackView.spacing = 10 // ?
            contentStackView.addArrangedSubview(subLabel)
            contentStackView.addArrangedSubview(mainLabel)
        }
        
        // SnapKit Layout
        self.snp.makeConstraints {
            $0.height.equalTo(type.height) // Enum에 정의된 높이 사용
        }
        
        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        
    }
    
    private func applyStyle() {
        self.backgroundColor = color.backgroundColor
        self.mainLabel.textColor = color.titleColor
    }
    
    // 여기는 왜 private 안 붙임?: ViewController가 써야 하니까
    func configure(title: String, subTitle: String? = nil, icon: UIImage? = nil) {
        mainLabel.text = title
        
        if let subTitle = subTitle {
            subLabel.text = subTitle
            subLabel.isHidden = false
        }
        
        if let icon = icon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        }
    }
}
