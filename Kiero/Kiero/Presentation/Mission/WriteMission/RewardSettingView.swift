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
    
    enum ViewType {
        case write
        case ai
        
        var buttonBackgroundColor: UIColor {
            switch self {
            case .write: return .gray900
            case .ai: return .gray800
            }
        }
        
        var buttonTitleColor: UIColor {
            switch self {
            case .write: return .gray500
            case .ai: return .white
            }
        }
    }
    
    // MARK: - Properties
    
    var selectedReward: Int {
        return currentRewardValue
    }
    
    private let viewType: ViewType
    private var currentRewardValue: Int = 20 {
        didSet {
            rewardTextField.text = "\(currentRewardValue)"
        }
    }
        
    // MARK: - UI Components
    
    private let rewardIcon = UIImageView(image: .ic3DCoin)
    private let rewardTitle = UILabel().then {
        $0.setTypo(.body2_16_R, text: "보상")
        $0.textColor = .white
    }
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.distribution = .fillEqually
    }
    
    let rewardTextField = UITextField().then {
        $0.text = "20"
        $0.font = .title3_16_SB
        $0.textColor = .white
        $0.textAlignment = .center
        $0.keyboardType = .numberPad
        $0.returnKeyType = .done
    }
    
    private let underline = UIView().then { $0.backgroundColor = .gray800 }
    
    // MARK: - Life Cycle
    
    init(type: ViewType) {
        self.viewType = type
        super.init(frame: .zero)
        setUI()
        setLayout()
        setDelegate()
        addTarget()
    }
    
    required init?(coder: NSCoder) { nil }
    
    // MARK: - Setup Methods
    
    private func setDelegate() {
        rewardTextField.delegate = self
    }
    
    private func addTarget() {
        rewardTextField.addTarget(self, action: #selector(textFieldDidEndEditing), for: .editingDidEnd)
    }
    
    private func createAdjustButton(title: String) -> UIButton {
        return UIButton().then {
            $0.setTitle(title, for: .normal)
            $0.titleLabel?.font = .title3_16_SB
            $0.setTitleColor(viewType.buttonTitleColor, for: .normal)
            $0.backgroundColor = viewType.buttonBackgroundColor
            $0.layer.cornerRadius = 15
            $0.addTarget(self, action: #selector(rewardButtonTapped(_:)), for: .touchUpInside)
        }
    }
    
    private func setUI() {
        addSubviews(rewardIcon, rewardTitle, stackView, rewardTextField, underline)
        
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
        
        rewardTextField.snp.makeConstraints {
            $0.center.equalTo(stackView)
            $0.width.equalTo(76)
        }
        
        underline.snp.makeConstraints {
            $0.top.equalTo(rewardTextField.snp.bottom).offset(11)
            $0.centerX.equalTo(rewardTextField)
            $0.width.equalTo(76)
            $0.height.equalTo(1)
        }
    }
    
    func selectReward(_ value: Int) {
        applyValueLimit(value)
    }
    
    // MARK: - Action Methods
    
    @objc private func rewardButtonTapped(_ sender: UIButton) {
        guard let title = sender.currentTitle, let value = Int(title) else { return }
        
        let newValue = currentRewardValue + value
        applyValueLimit(newValue)
        
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    @objc private func textFieldDidEndEditing() {
        guard let text = rewardTextField.text, let value = Int(text) else {
            rewardTextField.text = "\(currentRewardValue)"
            return
        }
        applyValueLimit(value)
    }
    
    private func applyValueLimit(_ value: Int) {
        if value < 1 {
            currentRewardValue = 1
            Toast.show(message: "최소 보상은 1개입니다.")
        } else if value > 500 {
            currentRewardValue = 500
          
            if viewType == .ai {
                Toast.show(message: "보상은 500개까지 설정할 수 있어요.", sideInset: 32, bottomInset: 300)
            } else {
                Toast.show(message: "보상은 500개까지 설정할 수 있어요.")
            }
            
        } else {
            currentRewardValue = value
        }
    }
}

extension RewardSettingView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        if !allowedCharacters.isSuperset(of: characterSet) { return false }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        return updatedText.count <= 3
    }
}
