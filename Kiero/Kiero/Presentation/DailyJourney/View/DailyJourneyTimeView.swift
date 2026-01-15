//
//  DailyJourneyTimeView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class DailyJourneyTimeView: BaseUIView {
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 15
        $0.clipsToBounds = true
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "여정 시간"
        $0.textColor = .gray400
        $0.font = .body3_14_R
    }
    
    private let timeStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 4
        $0.alignment = .firstBaseline
        $0.distribution = .fill
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubview(containerView)
        containerView.addSubviews(titleLabel, timeStackView)
    }
        
    override func setLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
        }
        
        timeStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
            $0.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(10)
        }
    }
    
    // MARK: - Configure
    
    func configure(title: String = "여정 시간", time: String) {
        titleLabel.text = title
        titleLabel.setTypo(.body3_14_R, text: title)
        
        setupTimeLabels(timeText: time)
    }
    
    private func setupTimeLabels(timeText: String) {
        timeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let components = timeText.components(separatedBy: " ")
        
        for text in components {
            let label = UILabel()
            label.text = text
            label.textColor = .main
            
            if text.contains("~") || text.contains(":") || text.rangeOfCharacter(from: .decimalDigits) != nil {
                label.setTypo(.body3_14_R, text: text)
            } else {
                label.setTypo(.body5_10_R, text: text)
            }
            timeStackView.addArrangedSubview(label)
        }
    }
}
