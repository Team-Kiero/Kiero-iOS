//
//  CalendarCell.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class CalendarCell: UICollectionViewCell {
    
    static let identifier = "CalendarCell"
    
    private let selectionView = UIView().then {
        $0.backgroundColor = .main
        $0.layer.cornerRadius = 18
        $0.isHidden = true
    }
    
    private let dateLabel = UILabel().then {
        $0.font = .body3_14_R
        $0.textColor = .kBlack
        $0.textAlignment = .center
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUI() {
        contentView.addSubviews(selectionView, dateLabel)
    }
    
    private func setLayout() {
        selectionView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(36)
        }
        
        dateLabel.snp.makeConstraints {
            $0.centerX.equalTo(selectionView)
            $0.centerY.equalTo(selectionView).offset(-1)
        }
    }
    
    func configure(date: Int, isCurrentMonth: Bool, isSelected: Bool, isToday: Bool, isEnabled: Bool) {
        dateLabel.text = "\(date)"
        
        if !isEnabled {
            dateLabel.textColor = .gray700
            selectionView.isHidden = true
        } else if isSelected {
            selectionView.isHidden = false
            selectionView.backgroundColor = .main
            dateLabel.textColor = .kBlack
        } else if isToday {
            selectionView.isHidden = false
            selectionView.backgroundColor = .gray800
            dateLabel.textColor = .gray400
        } else {
            selectionView.isHidden = true
            dateLabel.textColor = isCurrentMonth ? .gray100 : .gray700
        }
    }
}
