//
//  ContentEmptyView.swift
//  Kiero
//
//  Created by 정윤아 on 4/6/26.
//

import UIKit

import SnapKit
import Then

final class ContentEmptyView: BaseUIView {
    
    // MARK: - UI Components
    
    private let stackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 11
    }
    
    private let iconImage = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(resource: .icScheduleEmpty)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray500
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    private let descriptionLabel = UILabel().then {
        $0.textColor = .gray700
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    // MARK: - Init
    
    init(title: String, description: String, topOffset: CGFloat = 100) {
        super.init(frame: .zero)
        
        configure(title: title, description: description)
        updateTopOffset(topOffset)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Method
    
    override func setUI() {
        addSubview(stackView)
        stackView.addArrangedSubviews(
            iconImage,
            titleLabel,
            descriptionLabel
        )
    }
    
    override func setLayout() {
        iconImage.snp.makeConstraints {
            $0.width.equalTo(69)
            $0.height.equalTo(52)
        }
        
        stackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(100)
        }
        
        stackView.setCustomSpacing(4, after: titleLabel)
    }
    
    // MARK: - Methods
    
    private func configure(title: String, description: String) {
        titleLabel.setTypo(.title3_16_SB, text: title)
        descriptionLabel.setTypo(.body4_12_R, text: description)
    }
    
    private func updateTopOffset(_ offset: CGFloat) {
        stackView.snp.updateConstraints {
            $0.top.equalToSuperview().offset(offset)
        }
    }
}
