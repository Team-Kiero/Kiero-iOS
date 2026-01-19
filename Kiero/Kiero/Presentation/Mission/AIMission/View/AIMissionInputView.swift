//
//  AIMissionInputView.swift
//  Kiero
//
//  Created by 신혜연 on 1/15/26.
//

import UIKit

import SnapKit
import Then

final class AIMissionInputView: BaseUIView {
    
    // MARK: - Properties
    
    var onTextChanged: ((String) -> Void)?
    private var isUserTouched: Bool = false
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.setTypo(.title3_16_SB, text: "이곳에 알림장 내용을 붙여넣어 주세요.")
        $0.textColor = .gray200
    }
    
    let textView = UITextView().then {
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 15
        $0.textColor = .white
        $0.font = .body3_14_R
        $0.textContainerInset = UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)
        $0.returnKeyType = .done
        $0.isScrollEnabled = true
        $0.alwaysBounceVertical = true
        $0.showsVerticalScrollIndicator = false
        $0.contentInsetAdjustmentBehavior = .never
        $0.autocorrectionType = .no
    }
    
    private let placeholderLabel = UILabel().then {
        $0.text = "알림장 내용을 입력하세요."
        $0.font = .body3_14_R
        $0.textColor = .gray400
        $0.isUserInteractionEnabled = false
    }
    
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
        addSubviews(titleLabel, textView)
        textView.addSubview(placeholderLabel)
    }
    
    override func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(41)
            $0.leading.equalToSuperview().offset(15)
        }
        
        textView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(18)
        }
    }
    
    private func setDelegate() {
        textView.delegate = self
    }
    
    func activateTextView() {
        textView.isEditable = true
        textView.becomeFirstResponder()
    }
}

extension AIMissionInputView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        onTextChanged?(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return changedText.count <= 1000
    }
}

#Preview {
    AIMissionInputView()
}
