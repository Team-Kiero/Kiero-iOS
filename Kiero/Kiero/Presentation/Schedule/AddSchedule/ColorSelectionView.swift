//
//  ColorSelectionView.swift
//  Kiero
//
//  Created by 신혜연 on 7/9/26.
//

import UIKit

import SnapKit
import Then

final class ColorSelectionView: UIView {
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.setTypo(.title3_16_SB, text: "컬러")
        $0.textColor = .white
    }
    
    private let colorChip = ColorChip().then {
        $0.isUserInteractionEnabled = false
    }
    
    private let arrowIcon = UIImageView().then {
        $0.image = UIImage(resource: .icRight)
        $0.tintColor = .white
        $0.contentMode = .scaleAspectFit
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setUI()
        setLayout()
        addTarget()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        addSubviews(titleLabel, colorChip, arrowIcon)
        colorChip.isHidden = true
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        arrowIcon.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        colorChip.snp.makeConstraints {
            $0.trailing.equalTo(arrowIcon.snp.leading).offset(-10)
            $0.centerY.equalToSuperview()
        }
    }
    
    private func addTarget() {
        isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        addGestureRecognizer(tap)
    }
    
    func configure(with color: UIColor) {
        colorChip.isHidden = false
        colorChip.configure(with: color, isSelected: false)
    }
    
    @objc private func didTap() {
        onTap?()
    }
}
