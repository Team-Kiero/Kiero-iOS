//
//  ColorChip.swift
//  Kiero
//
//  Created by 신혜연 on 1/14/26.
//

import UIKit

import SnapKit
import Then

final class ColorChip: UIView {
    
    // MARK: - Properties
    
    var color: UIColor = .clear {
        didSet {
            backgroundColor = color
        }
    }
    
    var isSelected: Bool = false {
        didSet {
            checkMarkImageView.isHidden = !isSelected
        }
    }
    
    // MARK: - UI Components
    
    private let checkMarkImageView = UIImageView().then {
        $0.image = UIImage(resource: .icDoneBk).withRenderingMode(.alwaysTemplate)
        $0.tintColor = .gray900
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    private func setUI() {
        addSubview(checkMarkImageView)
    }
    
    private func setLayout() {
        checkMarkImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        self.snp.makeConstraints {
            $0.size.equalTo(35)
        }
    }
    
    func configure(with color: UIColor, isSelected: Bool) {
        self.color = color
        self.isSelected = isSelected
    }
}
