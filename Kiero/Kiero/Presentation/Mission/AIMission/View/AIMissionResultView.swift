//
//  AIMissionResultView.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class AIMissionResultView: BaseUIView {
    
    // MARK: - Propertie
    
    var onDeadlineViewTapped: (() -> Void)?
    
    var selectedReward: Int {
        return rewardView.selectedReward
    }
    
    // MARK: - UI Components
    
    let pagingHeader = PagingHeader()
    
    private let contentContainer = UIView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 15
    }
    
    let nameTextField = UITextField().then {
        $0.font = .body1_18_R
        $0.textColor = .white
        $0.returnKeyType = .done
        $0.attributedPlaceholder = NSAttributedString(
            string: "미션 이름을 입력해주세요.",
            attributes: [.foregroundColor: UIColor.gray800]
        )
    }

    let deadlineView = DeadlineSettingView()
    private let rewardView = RewardSettingView(type: .ai)
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setDelegate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubviews(pagingHeader, contentContainer)
        contentContainer.addSubviews(nameTextField, deadlineView, rewardView)
        
        pagingHeader.configure(title: "미션 1/5", isLeftEnabled: false, isRightEnabled: true)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deadlineViewDidTap))
        deadlineView.addGestureRecognizer(tapGesture)
        deadlineView.isUserInteractionEnabled = true
    }
    
    override func setLayout() {
        pagingHeader.snp.makeConstraints {
            $0.top.equalToSuperview().offset(21)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        contentContainer.snp.makeConstraints {
            $0.top.equalTo(pagingHeader.snp.bottom).offset(31)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(463)
        }
        
        nameTextField.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.horizontalEdges.equalToSuperview().inset(33)
        }
        
        deadlineView.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(32)
            $0.horizontalEdges.equalToSuperview().inset(34)
            $0.height.equalTo(48)
        }
        
        rewardView.snp.makeConstraints {
            $0.top.equalTo(deadlineView.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func setDelegate() {
        nameTextField.delegate = self
        
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(backgroundTap)
    }
    
    @objc
    private func deadlineViewDidTap() {
        onDeadlineViewTapped?()
    }
    
    @objc
    private func dismissKeyboard() {
        self.endEditing(true)
    }
}

extension AIMissionResultView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.count + string.count - range.length
        return newLength <= 15
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

#Preview {
    AIMissionResultView()
}
