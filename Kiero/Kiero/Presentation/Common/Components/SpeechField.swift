//
//  SpeechField.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/9/26.
//

import UIKit

import SnapKit
import Then

final class SpeechField: UIView {
    
    enum fieldType {
        case no
        case gray
        case main
        case endJourney

        var textColor: UIColor {
            switch self {
            case .no:
                return .clear
            case .gray, .endJourney:
                return .gray600
            case .main:
                return .main
            }
        }

        var buttonTitle: String {
            switch self {
            case .no:
                return ""
            case .gray:
                return "다음 여정으로"
            case .main:
                return "다음"
            case .endJourney:
                return "여정 끝내기"
            }
        }
    }
    
    private var type: fieldType
    
    var onTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let nameContainerView = UIView()
    
    private let containerView = UIView()
    
    private let buttonContainerView = UIView()
    
    private let nameLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    private let buttonLabel = UILabel().then {
        $0.isUserInteractionEnabled = true
    }
    
    private let buttonImage = UIImageView().then {
        $0.image = .icRight.withRenderingMode(.alwaysTemplate)
        $0.isUserInteractionEnabled = true
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    // MARK: - Life Cycle
    
    init(type: fieldType) {
        self.type = type
        super.init(frame: .zero)
        setStyle()
        setUI()
        setLayout()
        updateGestures()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setStyle() {
        nameContainerView.backgroundColor = .main
        nameContainerView.layer.cornerRadius = 4
        nameContainerView.clipsToBounds = true
        
        containerView.backgroundColor = .gray900
        containerView.layer.cornerRadius = 15
        containerView.clipsToBounds = true
        
        nameLabel.textColor = .kBlack
        
        contentStackView.backgroundColor = .clear
        buttonContainerView.backgroundColor = .clear
    }
    
    private func setUI() {
        addSubviews(containerView, nameContainerView, buttonContainerView)
        nameContainerView.addSubview(nameLabel)
        containerView.addSubview(contentStackView)
        buttonContainerView.addSubviews(buttonLabel, buttonImage)
    }
    
    private func setLayout() {
        nameContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.height.equalTo(21)
            $0.leading.equalTo(containerView.snp.leading).offset(18)
        }

        nameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 12))
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(nameContainerView.snp.bottom).offset(-2)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview()
        }
        
        contentStackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(14)
        }
        
        buttonContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(36)
            $0.trailing.equalTo(containerView.snp.trailing)
            $0.bottom.equalTo(nameContainerView.snp.bottom)
        }
        
        buttonImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(14)
        }
        
        buttonLabel.snp.makeConstraints {
            $0.trailing.equalTo(buttonImage.snp.leading)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(10)
        }
    }
    
    private func updateGestures() {
        self.gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        buttonContainerView.gestureRecognizers?.forEach { buttonContainerView.removeGestureRecognizer($0) }
        
        if type == .no { return }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(labelButtonDidTap))
        
        switch type {
        case .main:
            addGestureRecognizer(tap)
            buttonContainerView.isUserInteractionEnabled = false
        case .gray, .endJourney:
            buttonContainerView.addGestureRecognizer(tap)
            buttonContainerView.isUserInteractionEnabled = true
        case .no:
            break
        }
    }
    
    // MARK: - Configuration
    
    func configure(fieldType: fieldType, name: String, lines: [String], highlightKeywords: [String] = []) {
        
        self.type = fieldType
        
        buttonContainerView.isHidden = (fieldType == .no)
        
        updateGestures()
        nameLabel.setTypo(.body4_12_R, text: name)
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        buttonLabel.setTypo(.body6_10_R, text: type.buttonTitle)
        buttonLabel.textColor = type.textColor
        buttonImage.tintColor = type.textColor
        
        for line in lines {
            let label = UILabel().then {
                $0.numberOfLines = 0
                $0.textColor = .gray300
            }
            
            label.setTypo(.body3_14_R, text: line)
            
            if let currentAttr = label.attributedText {
                let mutableString = NSMutableAttributedString(attributedString: currentAttr)
                for keyword in highlightKeywords {
                    let range = (line as NSString).range(of: keyword)
                    if range.location != NSNotFound {
                        mutableString.addAttribute(.foregroundColor, value: UIColor.main, range: range)
                    }
                }
                label.attributedText = mutableString
            }
            contentStackView.addArrangedSubview(label)
        }
    }
    
    @objc
    private func labelButtonDidTap() {
        onTap?()
    }
}
