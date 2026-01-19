//
//  MissionBoxChild.swift
//  Kiero
//
//  Created by 정윤아 on 1/8/26.
//

import UIKit

import SnapKit
import Then

final class MissionBoxChild: UIView {
    
    // MARK: - State
    
    enum State {
        case inProgress
        case completed
        
        var backgroundColor: UIColor {
            switch self {
            case .inProgress: return .gray900
            case .completed: return UIColor.gray900.withAlphaComponent(0.6)
            }
        }
        
        var titleColor: UIColor {
            switch self {
            case .inProgress: return .white
            case .completed: return .white.withAlphaComponent(0.6)
            }
        }
        
        var rewardColor: UIColor {
            switch self {
            case .inProgress: return .gray400
            case .completed: return UIColor.gray400.withAlphaComponent(0.6)
            }
        }
        
        var buttonColor: UIColor {
            switch self {
            case .inProgress: return .white
            case .completed: return .clear
            }
        }
        
        var buttonTextColor: UIColor {
            switch self {
            case .inProgress: return .kBlack
            case .completed: return .white.withAlphaComponent(0.6)
            }
        }
        
        var buttonTitle: String {
            switch self {
            case .inProgress: return "완료"
            case .completed: return "성공!"
            }
        }
    }
    
    // MARK: - Properties
    
    var onTap: (() -> Void)?
    
    private var state: State = .inProgress
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 1
    }
    
    private let rewardLabel = UILabel()
    
    private let titleStack = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 4
    }
    
    private let completeButton = UIButton().then {
        $0.layer.cornerRadius = 8
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
        apply(state: .inProgress)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setStyle() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    private func setUI() {
        addSubview(missionBox)
        titleStack.addArrangedSubviews(rewardLabel, titleLabel)
        missionBox.addArrangedSubviews(titleStack, completeButton)
        
        completeButton.addTarget(self, action: #selector(didTapComplete), for: .touchUpInside)
    }
    
    private func setLayout() {
        missionBox.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(13)
            $0.verticalEdges.equalToSuperview().inset(13.5)
            $0.width.equalTo(343)
        }
        
        completeButton.snp.makeConstraints {
            $0.height.equalTo(40)
            $0.width.equalTo(70)
        }
    }
    
    // MARK: - Action
    
    @objc private func didTapComplete() {
        guard state == .inProgress else { return }
        onTap?()
    }
    
    // MARK: - Configuration
    
    func configure(name: String, reward: Int, state: State) {
        titleLabel.setTypo(.body2_16_R, text: name)
        rewardLabel.setTypo(.body4_12_R, text: "금화 \(reward) 개")
        apply(state: state)
        completeButton.setTypo(.title4_14_SB, text: state.buttonTitle, for: .normal)
    }
    
    // MARK: - Apply
    
    private func apply(state: State) {
        self.state = state
        
        backgroundColor = state.backgroundColor
        titleLabel.textColor = state.titleColor
        rewardLabel.textColor = state.rewardColor
        
        completeButton.backgroundColor = state.buttonColor
        completeButton.setTitleColor(state.buttonTextColor, for: .normal)
        
        completeButton.isEnabled = (state == .inProgress)
    }
}
