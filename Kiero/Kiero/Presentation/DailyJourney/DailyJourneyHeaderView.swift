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

    private let nameStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
    }

    private let dateLabel = UILabel().then {
        $0.textColor = .gray500
    }

    private let coinChip = ChipItem()
    private let fireStoneChip = ChipItem()

    // MARK: - Setup UI

    override func setUI() {
        nameStack.addArrangedSubviews(profileIcon, nameLabel)
        addSubviews(nameStack, coinChip, fireStoneChip, dateLabel)
    }

    override func setLayout() {
        nameStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.leading.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }

        profileIcon.snp.makeConstraints {
            $0.size.equalTo(40)
        }

        coinChip.snp.makeConstraints {
            $0.centerY.equalTo(nameStack)
            $0.trailing.equalToSuperview().inset(16)
        }

        fireStoneChip.snp.makeConstraints {
            $0.top.equalTo(coinChip.snp.bottom).offset(11)
            $0.trailing.equalToSuperview().inset(16)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(nameStack.snp.bottom).offset(10)
            $0.leading.equalToSuperview().inset(16)
        }
    }

    override func setStyle() {
        backgroundColor = .clear
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
