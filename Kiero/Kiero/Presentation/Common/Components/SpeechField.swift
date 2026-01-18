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
    
    // MARK: - UI Components
    
    private let nameContainerView = UIView()
    
    private let containerView = UIView()
    
    private let nameLabel = UILabel().then {
        $0.textAlignment = .center
    }
    
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.spacing = 10
        $0.alignment = .leading
        $0.distribution = .fill
    }
    
    // MARK: - Life Cycle
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setStyle()
        setUI()
        setLayout()
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
        nameLabel.font = .body5_10_R
        
        contentStackView.backgroundColor = .clear
    }
    
    private func setUI() {
        addSubviews(containerView, nameContainerView)
        nameContainerView.addSubview(nameLabel)
        containerView.addSubview(contentStackView)
    }
    
    private func setLayout() {
        nameContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.height.equalTo(21)
            $0.width.greaterThanOrEqualTo(43)
            $0.leading.equalTo(containerView.snp.leading).offset(18)
        }
        
        nameLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 2, left: 10, bottom: 2, right: 10))
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
    }
    
    // MARK: - Configuration
    
    func configure(name: String, lines: [String], highlightKeywords: [String] = []) {
        nameLabel.text = name
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for line in lines {
            let label = UILabel().then {
                $0.numberOfLines = 0
                $0.textColor = .gray300
            }
            
            label.setTypo(.body3_14_R, text: line)
            
            if let currentAttr = label.attributedText{
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
}
