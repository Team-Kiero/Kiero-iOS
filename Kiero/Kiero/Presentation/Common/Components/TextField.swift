//
//  TextField.swift
//  Kiero
//
//  Created by 안치욱 on 1/12/26.
//

import UIKit

import SnapKit
import Then

enum UserRole {
    case parent(ParentField)
    case child(ChildField)

    enum ParentField {
        case lastName
        case firstName
        case totalName
    }
    enum ChildField {
        case lastName
        case firstName
        case inviteCode
    }
}

extension UserRole {
    var title: String {
        switch self {
        case .parent(.lastName): return "아이의 성을 입력해주세요."
        case .parent(.firstName): return "아이의 이름을 입력해주세요."
        case .parent(.totalName): return ""
        case .child(.lastName): return "성"
        case .child(.firstName): return "이름"
        case .child(.inviteCode): return "초대 코드"
        }
    }

    var placeholder: String {
        switch self {
        case .parent(.lastName): return "성"
        case .parent(.firstName): return "이름"
        case .parent(.totalName): return ""
        case .child(.lastName): return "성을 입력해줘!"
        case .child(.firstName): return "이름을 입력해줘!"
        case .child(.inviteCode): return "부모님께 받은 비밀 암호를 입력해줘!"
        }
    }

    var regex: String? {
        switch self {
        case .parent(.lastName), .child(.lastName), .parent(.firstName), .parent(.totalName), .child(.firstName):
            return "^[가-힣]{0,5}$"
        case .child(.inviteCode):
            return nil
        }
    }

    var errorAppear: UIColor {
        switch self {
        case .parent(.lastName), .child(.lastName), .parent(.firstName), .child(.firstName):
            return .point
        case .parent(.totalName), .child(.inviteCode):
            return .clear
        }
    }
    
    var errorMessage: String {
        switch self {
        case .parent(.lastName), .parent(.firstName):
            return "특수문자나 이모지를 포함하지 않은 이름을 입력해주세요"
        case .child(.lastName), .child(.firstName):
            return "특수문자나 이모지를 포함하지 않은 이름을 입력해줘!"
        case .parent(.totalName), .child(.inviteCode):
            return "잘 하고 있다"
        }
    }
}

final class TextField: UIView {
    
    // MARK: - Properties
    
    private let type: UserRole
    
    private var hasInteracted: Bool = false
    
    weak var externalDelegate: UITextFieldDelegate?
    
    var onValidationChanged: ((Bool) -> Void)?
    
    var innerTextField: UITextField { textField }
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.textColor = .gray400
    }
    
    private let textField = UITextField().then {
        $0.defaultTextAttributes = [
            .kern: -0.005,
            .font: UIFont.body4_12_R,
            .foregroundColor: UIColor.white
        ]
        $0.addLeftPadding(13)
        $0.backgroundColor = .gray900
        $0.layer.cornerRadius = 15
    }
    
    private let errorImage = UIImageView().then {
        $0.alpha = 0
    }
    
    private let errorLabel = UILabel().then {
        $0.alpha = 0
    }
    
    // MARK: - Life Cycle
    
    init(type: UserRole) {
        self.type = type
        super.init(frame: .zero)
        setStyle()
        setUI()
        setLayout()
        setDelegate()
        configure(type: type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        switch type {
        case .parent(.lastName), .child(.firstName), .child(.lastName):
            return textField.returnKeyType = .next
        case .parent(.firstName), .parent(.totalName), .child(.inviteCode):
            return textField.returnKeyType = .done
        }
    }
    
    private func setUI() {
        addSubviews(
            titleLabel,
            textField,
            errorImage,
            errorLabel
        )
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(16)
        }
        
        textField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(45)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(6)
            $0.trailing.equalToSuperview().inset(16)
        }
        
        errorImage.snp.makeConstraints {
            $0.centerY.equalTo(errorLabel.snp.centerY)
            $0.trailing.equalTo(errorLabel.snp.leading).offset(-4)
        }
    }
    
    private func setDelegate() {
        textField.delegate = self
    }
    
    private func configure(type: UserRole) {
        titleLabel.setTypo(.body3_14_R, text: type.title)
        titleLabel.isHidden = type.title.isEmpty
        errorLabel.textColor = type.errorAppear
        errorImage.image = .icInfo
            .withTintColor(.point)
            .resized(to: CGSize(width: 11, height: 11))
        textField.attributedPlaceholder = NSAttributedString(
                string: type.placeholder,
                attributes: [
                    .kern: -0.005,
                    .font: UIFont.body4_12_R,
                    .foregroundColor: UIColor.gray700
                ]
            )
    }
    
    func setText(text: String) {
        textField.text = text
    }
    
    private func validate() {
        textField.layer.borderWidth = 0
        textField.layer.borderColor = UIColor.clear.cgColor
        
        guard let regex = type.regex else {
                onValidationChanged?(true)
                return
            }
        
        let text = (textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        
        if textField.text == nil || textField.text == ""{
            textField.layer.borderColor = UIColor.white.cgColor
            textField.layer.borderWidth = 0
            errorLabel.alpha = 0
            errorImage.alpha = 0
        }
        
        guard hasInteracted else { return }
        guard !text.isEmpty else { return }
        
        let isValid = NSPredicate(
            format: "SELF MATCHES %@",
            regex
        ).evaluate(with: text)
        
        updateErrorUI(isValid: isValid)
        onValidationChanged?(isValid)
    }
    
    private func isValidInput(_ raw: String) -> Bool {
        guard let regex = type.regex else { return true }

        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !text.isEmpty else { return false }

        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: text)
    }
    
    private func updateErrorUI(isValid: Bool) {
        if isValid {
            textField.layer.borderWidth = 0
            textField.layer.borderColor = UIColor.clear.cgColor
            errorImage.alpha = 0
            errorLabel.alpha = 0
            return
        }
        
        errorLabel.setTypo(.body5_10_R, text: type.errorMessage)
        errorLabel.alpha = 1
        errorImage.alpha = 1
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.point.cgColor
    }
}

extension TextField: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        hasInteracted = true
        textField.layer.borderColor = UIColor.gray100.cgColor
        textField.layer.borderWidth = 1
        errorLabel.alpha = 0
        errorImage.alpha = 0

        externalDelegate?.textFieldDidBeginEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        validate()
        externalDelegate?.textFieldDidEndEditing?(textField)
    }

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {

        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        if string.contains(where: { $0.isWhitespace }) {
            return false
        }

        let lengthOK: Bool = {
            switch type {
            case .parent(.firstName), .parent(.lastName), .parent(.totalName),
                 .child(.firstName), .child(.lastName):
                return updatedText.count <= 5
            case .child(.inviteCode):
                return updatedText.count <= 25
            }
        }()

        guard lengthOK else { return false }

        let externalOK = externalDelegate?
            .textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
        
        return externalOK
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let externalOK = externalDelegate?.textFieldShouldReturn?(textField) ?? true
        if externalOK { textField.resignFirstResponder() }
        return externalOK
    }
}
