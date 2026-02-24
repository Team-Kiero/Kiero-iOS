//
//  DayItem.swift
//  Kiero
//
//  Created by 신혜연 on 1/12/26.
//

import UIKit

import SnapKit
import Then

final class DayItem: BaseUIView {
    
    private let dayLabel = UILabel().then {
        $0.textAlignment = .center
    }

    func configure(day: String, isToday: Bool) {
        dayLabel.setTypo(.body6_10_R, text: day)
        dayLabel.textColor = isToday ? .main : .gray100
    }

    override func setUI() {
        addSubviews(dayLabel)
    }

    override func setLayout() {
        dayLabel.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
    }
}
