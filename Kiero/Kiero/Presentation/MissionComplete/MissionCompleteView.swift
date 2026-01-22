//
//  MissionCompleteView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/15/26.
//

import Combine
import UIKit

import SnapKit
import Then

final class MissionCompleteView: BaseUIView {
    
    // MARK: - UI Components
    
    let backgroundImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    let blackOverlayView = UIView().then {
        $0.backgroundColor = UIColor.kBlack.withAlphaComponent(0.6)
    }
    
    let speechField = SpeechField(type: .no).then {
        $0.isHidden = false
    }
    
    let fireStoneImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.shadowColor = UIColor.white.cgColor
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 10
        $0.layer.shadowOffset = .zero
    }
    
    let kkubiImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgGoblinSmile)
        $0.contentMode = .scaleAspectFit
    }
    
    override func setUI() {
        addSubviews(backgroundImageView, blackOverlayView, kkubiImageView, fireStoneImageView, speechField)
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints { $0.edges.equalToSuperview() }
        blackOverlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        kkubiImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(252)
            $0.height.equalTo(286)
        }
        
        fireStoneImageView.snp.makeConstraints {
            $0.bottom.equalTo(kkubiImageView.snp.top).offset(19)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(140)
        }
        
        speechField.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(131)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func configure(capturedImage: UIImage?, rewardImage: UIImage, message: String, keyword: String) {
        self.backgroundImageView.image = capturedImage
        self.fireStoneImageView.image = rewardImage
        
        speechField.configure(
            fieldType: .no,
            name: "꾸비",
            lines: [message],
            highlightKeywords: [keyword]
        )
    }
    
    func startFloatingAnimation(completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        
        let animation = CABasicAnimation(keyPath: "transform.translation.y")
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = 2
        animation.fromValue = 0
        animation.toValue = -16
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.isRemovedOnCompletion = true
        
        fireStoneImageView.layer.add(animation, forKey: "missionSuccess")
        
        CATransaction.commit()
    }
}
