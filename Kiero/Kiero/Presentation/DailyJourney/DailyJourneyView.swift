//
//  DailyJourneyView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/13/26.
//

import UIKit
import Combine
import ImageIO

import Kingfisher
import KingfisherWebP
import SnapKit
import Then

final class DailyJourneyView: BaseUIView {
    
    var onNextJourneyTap: (() -> Void)?
    
    // MARK: - UI Components
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgBackground)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let dimOverlayView = UIView().then {
        $0.backgroundColor = UIColor.kBlack.withAlphaComponent(0.6)
        $0.isUserInteractionEnabled = false
    }
    
    private let backgroundMaskView = UIView().then {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        
        gradientLayer.colors = [
            UIColor(white: 1.0, alpha: 1.0).cgColor,
            UIColor(white: 1.0, alpha: 1.0).cgColor,
            UIColor(white: 1.0, alpha: 0.85).cgColor,
            UIColor(white: 1.0, alpha: 0.65).cgColor,
            UIColor(white: 1.0, alpha: 0.45).cgColor,
            UIColor(white: 1.0, alpha: 0.25).cgColor,
            UIColor(white: 1.0, alpha: 0.12).cgColor,
            UIColor(white: 1.0, alpha: 0.0).cgColor
        ]
        
        gradientLayer.locations = [
            0.0,
            0.75,
            0.82,
            0.88,
            0.92,
            0.95,
            0.97,
            1.0
        ] as [NSNumber]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        $0.layer.addSublayer(gradientLayer)
    }
    
    private let headerView = DailyJourneyHeaderView()
    
    private let journeyTimeView = DailyJourneyTimeView()
    
    private let kkubiCharacterImageView = AnimatedImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    private let speechField = SpeechField(type: .gray)
    
    let verifyPhotoButton = CTAButton(style: .gray100, size: .h49).then {
        $0.configure(
            title: "인증하고 불조각 받기",
            icon: UIImage(resource: .icCamera).withRenderingMode(.alwaysTemplate)
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundMaskView.frame = backgroundImageView.bounds
        
        if let gradientLayer = backgroundMaskView.layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = backgroundMaskView.bounds
        }
        
        backgroundImageView.mask = backgroundMaskView
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubviews(backgroundImageView, dimOverlayView, headerView, journeyTimeView, kkubiCharacterImageView, speechField, verifyPhotoButton)
        
        speechField.onTap = { [weak self] in
            self?.onNextJourneyTap?()
        }

        loadIntroWebP()
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(126)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(410)
            $0.height.equalTo(437)
        }
        
        dimOverlayView.snp.makeConstraints {
            $0.edges.equalTo(backgroundImageView)
        }
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(59)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(67)
        }
        
        journeyTimeView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(22)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(50)
        }
        
        verifyPhotoButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(114)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        speechField.snp.makeConstraints {
            $0.bottom.equalTo(verifyPhotoButton.snp.top).offset(-27)
            $0.horizontalEdges.equalToSuperview()
        }
        
        kkubiCharacterImageView.snp.makeConstraints {
            $0.top.equalTo(journeyTimeView.snp.bottom).offset(60)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
            $0.height.equalTo(343)
        }
    }
    
    private func loadIntroWebP() {
        if let url = Bundle.main.url(forResource: "kkubi_intro", withExtension: "webp") {
            
            let processor = WebPProcessor.default
            let serializer = WebPSerializer.default
            
            kkubiCharacterImageView.kf.setImage(
                with: url,
                options: [
                    .processor(processor),
                    .cacheSerializer(serializer)
                ]
            )
        } else {
            print("⚠️ webp 파일을 Bundle에서 찾을 수 없습니다.")
        }
    }
    
    // MARK: - Update Methods
    
    func updateData(with data: DailyJourneyModel) {
        headerView.configure(
            kidName: data.kidName,
            date: data.dateText,
            coinCount: data.coinCount,
            fireStoneCount: data.fireStoneCount,
            maxFireStoneCount: data.maxFireStoneCount,
            chipType: data.chipItemType
        )
        
        journeyTimeView.isHidden = !data.isTimeViewActive
        
        if data.isTimeViewActive {
            journeyTimeView.configure(
                title: "\(data.scheduleOrderText)번째 여정 시간",
                time: data.journeyTimeText
            )
        }
        
        let lines = data.bubbleText.components(separatedBy: "\n")
        
        speechField.configure(
            fieldType: data.speechFieldType,
            name: "꾸비",
            lines: lines,
            highlightKeywords: data.highlightKeywords
        )
        
        switch data.actionButtonType {
        case .verify:
            verifyPhotoButton.isHidden = false
            verifyPhotoButton.configure(
                title: "인증하고 불조각 받기",
                icon: UIImage(resource: .icCamera)
            )
            
        case .lightFire:
            verifyPhotoButton.isHidden = false
            verifyPhotoButton.configure(
                title: "마음의 불꽃 피워주기",
                icon: UIImage(resource: .icFire)
            )
            
        case .hidden:
            verifyPhotoButton.isHidden = true
        }
    }
}
