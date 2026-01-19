//
//  WishBox.swift
//  Kiero
//
//  Created by 정윤아 on 1/9/26.
//

import UIKit

import SnapKit
import Then

final class WishBox: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 1
    }
    
    private let rewardLabel = UILabel().then {
        $0.textColor = .gray400
        $0.numberOfLines = 1
    }
    
    private let titleStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let completeButton = UIButton().then {
        $0.titleLabel?.font = .title4_14_SB
        $0.setTitle("소원빌기", for: .normal)
        $0.setTitleColor(.kBlack, for: .normal)
        $0.layer.cornerRadius = 8
        $0.backgroundColor = .white
    }
    
    private let wishBox = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.spacing = 14
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setStyle() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
        backgroundColor = .gray900
    }
    
    private func setUI() {
        addSubview(wishBox)
        titleStack.addArrangedSubviews(rewardLabel, titleLabel)
        wishBox.addArrangedSubviews(titleStack, completeButton)
        
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
    }
    
    private func setLayout() {
        wishBox.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.verticalEdges.equalToSuperview().inset(13)
        }
        
        completeButton.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }
    
    // MARK: - Action
    
    @objc private func didTapComplete() {
        onTap?()
    }
    
    // MARK: - Configuration
    
    func configure(name: String, price: Int) {
        titleLabel.setTypo(.body3_14_R, text: name)
        rewardLabel.setTypo(.body4_12_R, text: "금화 \(price) 개")
    }
}
