//
//  DeadlineSettingView.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class DeadlineSettingView: UIView {
    
    private let titleLabel = UILabel().then {
        $0.text = "마감일"
        $0.font = .body3_14_R
        $0.textColor = .gray200
    }
    
    let dateLabel = UILabel().then {
        $0.text = Date().toString()
        $0.font = .title3_16_SB
        $0.textColor = .gray200
    }
    
    private let calendarIcon = UIImageView().then {
        $0.image = .icCalender
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    private func setUI() {
        addSubviews(titleLabel, dateLabel, calendarIcon)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.centerY.equalToSuperview()
        }
        
        calendarIcon.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalTo(calendarIcon.snp.leading).offset(-6)
            $0.centerY.equalToSuperview()
        }
    }
}
