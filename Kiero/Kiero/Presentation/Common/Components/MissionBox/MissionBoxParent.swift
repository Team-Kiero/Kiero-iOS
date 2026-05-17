//
//  MissionBoxParent.swift
//  Kiero
//
//  Created by 정윤아 on 1/8/26.
//

import UIKit

import SnapKit
import Then

final class MissionBoxParent: UIView {
    
    // MARK: - State
    
    enum State {
        case inProgress
        case completed
    }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 1
    }
    
    private let rewardIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let rewardLabel = UILabel().then {
        $0.textColor = .gray400
    }

    private let badgeRewardLabel = UILabel().then {
        $0.textColor = .gray500
    }
    
    private let rewardStackView = UIStackView().then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
        $0.spacing = 6
        $0.alignment = .center
    }
    
    private let titleStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let missionBox = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
    }
    
    private let successLabel = UILabel().then {
        $0.setTypo(.title4_14_SB, text: "성공!")
        $0.textColor = .white.withAlphaComponent(0.5)
        $0.isHidden = true
    }
    
    private let rewardBadge = UIView()
    
    private let spacer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setStyle()
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setStyle() {
        backgroundColor = .gray900
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        rewardStackView.layer.borderColor = UIColor.gray500.cgColor
        rewardIcon.image = .ic3DCoin
        rewardStackView.insetsLayoutMarginsFromSafeArea = false
        rewardStackView.isLayoutMarginsRelativeArrangement = true
        rewardStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    private func setUI() {
        addSubview(missionBox)
        titleStack.addArrangedSubviews(rewardLabel, titleLabel)
        missionBox.addArrangedSubviews(titleStack, spacer, rewardStackView, successLabel)
        rewardStackView.addArrangedSubviews(rewardIcon, badgeRewardLabel)
    }
    
    private func setLayout() {
        missionBox.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(13)
            $0.trailing.equalToSuperview().inset(13)
            $0.verticalEdges.equalToSuperview().inset(0)
        }
        
        snp.makeConstraints {
            $0.height.equalTo(64)
        }
        
        spacer.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(10)
        }
        
        rewardStackView.snp.makeConstraints {
            $0.height.equalTo(24)
        }
        
        rewardIcon.snp.makeConstraints {
            $0.size.equalTo(16)
        }
    }
    
    // MARK: - Configuration
    
    func configure(name: String, reward: Int, isCompleted: Bool = false) {
        rewardLabel.setTypo(.body4_12_R, text: "금화 \(reward) 개")
        badgeRewardLabel.setTypo(.body6_10_R, text: "\(reward) 개")
        apply(state: isCompleted ? .completed : .inProgress)
        
        if isCompleted {
            titleLabel.setTypo(.body2_16_R, text: name)
            titleLabel.textColor = .white.withAlphaComponent(0.5)
        } else {
            titleLabel.setTypo(.title3_16_SB, text: name)
            titleLabel.textColor = .white
        }
    }
    
    private func apply(state: State) {
        switch state {
        case .inProgress:
            backgroundColor = .gray900
            titleLabel.textColor = .white
            rewardLabel.isHidden = true
            rewardStackView.isHidden = false
            successLabel.isHidden = true
            missionBox.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(13)
            }

        case .completed:
            backgroundColor = .gray900.withAlphaComponent(0.5)
            titleLabel.textColor = .white.withAlphaComponent(0.5)
            rewardLabel.textColor = .gray400.withAlphaComponent(0.5)
            rewardLabel.isHidden = false
            rewardStackView.isHidden = true
            successLabel.isHidden = false
            missionBox.snp.updateConstraints {
                $0.trailing.equalToSuperview().inset(32)
            }
        }
    }
}
