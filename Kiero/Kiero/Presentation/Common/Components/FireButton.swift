//
//  FireButton.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/9/26.
//

import UIKit

import SnapKit
import Then

final class FireButton: UIButton {
    
    // MARK: - UI Components
    
    private let mainStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .center
        $0.distribution = .fill
        $0.isUserInteractionEnabled = false
    }
    
    private let topInfoStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    private let fireIconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "ic_fire")?.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .main
    }
    
    private let countLabel = UILabel().then {
        $0.textColor = .gray500
        $0.textAlignment = .center
    }
    
    private let mainLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    // MARK: - Init
    
    init() {
        super.init(frame: .zero)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Set
    
    private func setUI() {
        self.backgroundColor = .gray900
        self.layer.cornerRadius = 8
        self.clipsToBounds = true
        
        addSubview(mainStackView)
        
        topInfoStackView.addArrangedSubviews(fireIconImageView, countLabel)
        mainStackView.addArrangedSubviews(topInfoStackView, mainLabel)
        
        self.snp.makeConstraints {
            $0.height.equalTo(81)
        }
        
        mainStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        fireIconImageView.snp.makeConstraints {
            $0.size.equalTo(20)
        }
    }
    
    // MARK: - Configuration
    
    func configure(title: String, count: Int) {
        mainLabel.setTypo(.title3_16_SB, text: title)
        mainLabel.textColor = .white
        
        countLabel.setTypo(.body2_16_R, text: "\(count) 개")
        countLabel.textColor = .gray500
    }
}
