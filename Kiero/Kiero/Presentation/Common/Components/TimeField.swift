//
//  TimeField.swift
//  Kiero
//
//  Created by 신혜연 on 1/11/26.
//

import UIKit

import SnapKit
import Then

final class TimeField: UIView {
    
    // MARK: - Properties
    
    var isSelected: Bool = false {
        didSet {
            updateStyle()
        }
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.font = .body5_10_R
        $0.text = "시작"
    }
    
    private let timeLabel = UILabel().then {
        $0.font = .title2_20_SB
        $0.text = "09 : 00 AM"
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
        self.backgroundColor = .kBlack
        self.layer.cornerRadius = 12
        self.layer.borderWidth = 1
        updateStyle()
    }
    
    private func setUI() {
        addSubviews(titleLabel, timeLabel)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(137)
            $0.height.equalTo(78)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
        }
        
        timeLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(16)
            $0.leading.equalTo(titleLabel)
        }
    }
    
    func configure(title: String, time: String) {
        titleLabel.text = title
        timeLabel.text = time
    }
    
    private func updateStyle() {
        if isSelected {
            self.layer.borderColor = UIColor.gray900.cgColor
            titleLabel.textColor = .main
            timeLabel.textColor = .main
        } else {
            self.layer.borderColor = UIColor.gray900.cgColor
            titleLabel.textColor = .white
            timeLabel.textColor = .white
        }
    }
}
