//
//  SpeechBubble.swift
//  Kiero
//
//  Created by 안치욱 on 1/14/26.
//

import UIKit

import SnapKit
import Then

final class SpeechBubble: UIView {
    
    // MARK: - UI Components
    
    private let labelView = UIView().then {
        $0.layer.cornerRadius = 15
        $0.backgroundColor = .gray900
    }
    
    private let triangleView = DownTriangleView().then {
        $0.fillColor = .gray900
        $0.cornerRadius = 2
    }
    
    private let speechLabel = UILabel()
    
    // MARK: - Life Cycle
    
    init(speech: String) {
        super.init(frame: .zero)
        setUI()
        setLayout()
        configure(speech: speech)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setting Methods
    
    private func setUI() {
        addSubviews(
            labelView,
            triangleView
        )
        labelView.addSubview(speechLabel)
    }
    
    private func setLayout() {
        labelView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }
        
        speechLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(12.5)
        }
        
        triangleView.snp.makeConstraints {
            $0.top.equalTo(labelView.snp.bottom).offset(-3)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(19)
            $0.height.equalTo(16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func configure(speech: String) {
        speechLabel.setTypo(.body3_14_R, text: speech)
        speechLabel.textColor = .gray300
    }
}
