//
//  NotificationSectionHeaderView.swift
//  Kiero
//
//  Created by 정윤아 on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class NotificationSectionHeaderView: BaseUIView {
    
    // MARK: - Properties
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray200
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubview(dateLabel)
    }
    
    override func setLayout() {
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
        }
    }

    func configure(date: String) {
        dateLabel.setTypo(.title3_16_SB, text: date)
    }
}
