//
//  DailyJourneyHeaderView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/12/26.
//

import UIKit

import SnapKit
import Then

final class DailyJourneyHeaderView: BaseUIView {
    
    // MARK: - UI Components
    
    private let profileIcon = UIImageView().then {
        $0.image = UIImage(resource: .icKidProfile)
        $0.contentMode = .scaleAspectFit
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray500
    }
    
    private let coinChip = ChipItem()
    
    private let fireStoneChip = ChipItem()
    
    private let chipStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 11
        $0.alignment = .trailing
        $0.distribution = .fill
    }
    
    // MARK: - Setup UI
    
    override func setUI() {
        addSubviews(profileIcon, nameLabel, dateLabel, chipStackView)
        chipStackView.addArrangedSubviews(coinChip, fireStoneChip)
    }
    
    override func setLayout() {
        profileIcon.snp.makeConstraints {
            $0.top.equalToSuperview().offset(5)
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(40)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileIcon.snp.trailing).offset(6)
            $0.centerY.equalTo(profileIcon)
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(profileIcon)
        }
        
        chipStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
    }
    
    override func setStyle() {
        self.backgroundColor = .clear
    }
    
    // MARK: - Configure
    
    func configure(
        kidName: String,
        date: String,
        coinCount: Int,
        fireStoneCount: Int,
        maxFireStoneCount: Int,
        chipType: ChipItem.ChipStyle
    ) {
        nameLabel.setTypo(.title3_16_SB, text: kidName)
        dateLabel.setTypo(.body3_14_R, text: date)
        
        let coinImg = UIImage(resource: .ic3DCoin)
        let stoneImg = UIImage(resource: .ic3DBluestone)
        
        coinChip.configure(style: .currentCoinChip, icon: coinImg, text: "\(coinCount) 개")
        fireStoneChip.configure(style: chipType, icon: stoneImg, text: "\(fireStoneCount) / \(maxFireStoneCount) 개")
    }
}
