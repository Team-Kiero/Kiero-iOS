//
//  WishEmptyView.swift
//  Kiero
//
//  Created by 정윤아 on 3/4/26.
//

import UIKit

import SnapKit
import Then

final class WishEmptyView: UIView {
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 11
    }
    
    private let iconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(resource: .icKidProfile)
        $0.tintColor = .gray700
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.setTypo(.title3_16_SB, text: "아직 등록된 보상이 없어!")
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .gray500
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.setTypo(.body4_12_R, text: "부모님과 함께 나만의 보상을 정해볼까?")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        addSubview(stackView)
        stackView.addArrangedSubviews(iconImage, titleLabel, descriptionLabel)
    }
    
    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(76.5)
        }
        
        iconImage.snp.makeConstraints {
            $0.width.equalTo(69)
            $0.height.equalTo(52)
        }
        
        stackView.setCustomSpacing(4, after: titleLabel)
    }
}
