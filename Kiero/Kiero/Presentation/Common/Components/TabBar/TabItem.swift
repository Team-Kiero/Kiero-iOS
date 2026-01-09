//
//  TabItem.swift
//  Kiero
//
//  Created by 신혜연 on 1/9/26.
//

import UIKit

import SnapKit
import Then

final class TabItem: UIView {
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 4
        $0.alignment = .center
        $0.isUserInteractionEnabled = false
    }
    
    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.font = .body5_10_R
    }
    
    var isSelected: Bool = false {
        didSet {
            iconImageView.tintColor = isSelected ? .white : .gray800
            titleLabel.textColor = isSelected ? .gray100 : .gray800
        }
    }
    
    init(title: String, image: UIImage?) {
        super.init(frame: .zero)
        iconImageView.image = image?.withRenderingMode(.alwaysTemplate)
        titleLabel.text = title
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setUI() {
        addSubview(stackView)
        stackView.addArrangedSubviews(iconImageView, titleLabel)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.size.equalTo(24)
        }
    }
}
