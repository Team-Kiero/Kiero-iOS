//
//  MissionBoxParentView.swift
//  Kiero
//
//  Created by 정윤아 on 1/8/26.
//

import UIKit

import SnapKit
import Then

final class MissionBoxParentView: UIView {
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.numberOfLines = 1
    }
    
    private let rewardIcon = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let rewardLabel = UILabel().then {
        $0.textColor = .gray500
    }
    
    private let rewardStackView = UIStackView().then {
        $0.backgroundColor = .clear
        $0.layer.borderWidth = 1
        $0.layer.cornerRadius = 12
        $0.spacing = 6
    }
    
    private let missionBox = UIStackView().then {
        $0.axis = .horizontal 
        $0.alignment = .center
    }
    
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

        rewardStackView.layer.borderColor = UIColor(named: "gray_500")?.cgColor
        rewardIcon.image = UIImage(named: "ic_3d_coin")
    }
    
    private func setUI() {
        addSubview(missionBox)
        missionBox.addArrangedSubviews(titleLabel, rewardStackView)
        rewardStackView.addArrangedSubviews(rewardIcon, rewardLabel)
    }
    
    private func setLayout() {
        missionBox.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(13)
        }
        
        rewardStackView.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.equalTo(61)
        }
        
        rewardIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(16)
        }
        
        rewardLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
        }
    }
    
    // MARK: - Configuration
    
    func configure(name: String, reward: Int) {
        titleLabel.setTypo(.title3_16_SB, text: name)
        rewardLabel.setTypo(.body5_10_R, text: "\(reward)개")
        }
}
