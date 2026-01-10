//
//  PagingHeader.swift
//  Kiero
//
//  Created by 신혜연 on 1/10/26.
//

import UIKit

import SnapKit
import Then

final class PagingHeader: UIView {
    
    // MARK: - Properties
    
    var onLeftButtonTapped: (() -> Void)?
    var onRightButtonTapped: (() -> Void)?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .title4_14_SB
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private lazy var leftButton = UIButton().then {
        $0.setImage(UIImage(resource: .icLeft), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(leftTapped), for: .touchUpInside)
    }
    
    private lazy var rightButton = UIButton().then {
        $0.setImage(UIImage(resource: .icRight), for: .normal)
        $0.tintColor = .white
        $0.addTarget(self, action: #selector(rightTapped), for: .touchUpInside)
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        self.backgroundColor = .clear
    }
    
    private func setUI() {
        addSubviews(leftButton, titleLabel, rightButton)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.lessThanOrEqualTo(200)
        }
        
        leftButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-84)
            $0.size.equalTo(24)
        }
        
        rightButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(84)
            $0.size.equalTo(24)
        }
    }
    
    // MARK: - Public Methods
    
    func configure(title: String, isLeftEnabled: Bool, isRightEnabled: Bool) {
        titleLabel.text = title
        
        leftButton.isEnabled = isLeftEnabled
        leftButton.alpha = isLeftEnabled ? 1.0 : 0.2
        leftButton.tintColor = .white
        
        rightButton.isEnabled = isRightEnabled
        rightButton.alpha = isRightEnabled ? 1.0 : 0.2
        rightButton.tintColor = .white
    }
    
    @objc private func leftTapped() { onLeftButtonTapped?() }
    @objc private func rightTapped() { onRightButtonTapped?() }
}
