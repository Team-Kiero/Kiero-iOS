//
//  RewardSettingView.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class RewardSettingView: UIView {
    
    // MARK: - Properties
    
    private var currentRewardValue: Int = 20 {
        didSet {
            currentRewardLabel.text = "\(currentRewardValue)"
        }
    }
    
    // MARK: - UI Components
    
    private let rewardIcon = UIImageView(image: .ic3DCoin)
    
    private let rewardTitle = UILabel().then {
        $0.text = "보상"
        $0.font = .body2_16_R
        $0.textColor = .white
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    private func createAdjustButton(title: String) -> UIButton {
        return UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .title3_16_SB
            $0.setTitleColor(.gray500, for: .normal)
            $0.backgroundColor = .gray900
            $0.layer.cornerRadius = 15
            $0.addTarget(self, action: #selector(rewardButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    let currentRewardLabel = UILabel().then {
        $0.text = "20"
        $0.font = .title3_16_SB
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    private let underline = UIView().then { $0.backgroundColor = .gray800 }

    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setUI() {
        addSubviews(rewardIcon, rewardTitle, stackView, currentRewardLabel, underline)
        
        stackView.addArrangedSubviews(
            createAdjustButton(title: "-10"),
            createAdjustButton(title: "-5"),
            UIView(),
            createAdjustButton(title: "+5"),
            createAdjustButton(title: "+10")
        )
    }
    
    private func setLayout() {
        rewardIcon.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.size.equalTo(24)
        }
        
        rewardTitle.snp.makeConstraints {
            $0.leading.equalTo(rewardIcon.snp.trailing).offset(4)
            $0.centerY.equalTo(rewardIcon)
        }
        
        stackView.snp.makeConstraints {
            $0.top.equalTo(rewardTitle.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        currentRewardLabel.snp.makeConstraints {
            $0.center.equalTo(stackView)
        }
        
        underline.snp.makeConstraints {
            $0.top.equalTo(currentRewardLabel.snp.bottom).offset(11)
            $0.centerX.equalTo(currentRewardLabel)
            $0.width.equalTo(76)
            $0.height.equalTo(1)
        }
    }
    
    @objc private func rewardButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let value = Int(title) else { return }
        
        let newValue = currentRewardValue + value
        currentRewardValue = max(0, newValue)
        
        let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        feedbackGenerator.impactOccurred()
    }
    
    func getRewardValue() -> Int {
        return currentRewardValue
    }
}
