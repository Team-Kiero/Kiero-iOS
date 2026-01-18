//
//  DailyJourneyView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/13/26.
//

import UIKit
import Combine

import Kingfisher
import SnapKit
import Then

final class DailyJourneyView: BaseUIView {
    
    // MARK: - UI Components
    
    private let backgroundImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgBackground)
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let backgroundMaskView = UIView().then {
        let gradientLayer = CAGradientLayer()
        gradientLayer.type = .radial
        gradientLayer.colors = [UIColor.black.cgColor, UIColor.clear.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.locations = [0.0, 1.0]
        $0.layer.addSublayer(gradientLayer)
    }
    
    private let headerView = DailyJourneyHeaderView()
    
    private let journeyTimeView = DailyJourneyTimeView()
    
    private let kkubiCharacterImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    let goToNextButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        config.baseForegroundColor = .gray600
        
        let originalImage = UIImage(resource: .icRight)
        let targetSize = CGSize(width: 14, height: 14)
        let resizedImage = UIGraphicsImageRenderer(size: targetSize).image { _ in
            originalImage.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        
        config.image = resizedImage
        config.imagePlacement = .trailing
        config.imagePadding = 0
        
        var titleContainer = AttributeContainer()
        
        titleContainer.font = .body5_10_R
        titleContainer.foregroundColor = .gray600
        
        config.attributedTitle = AttributedString("다음 여정으로", attributes: titleContainer)
        config.contentInsets = .zero
        
        $0.configuration = config
        $0.layer.cornerRadius = 4
        $0.clipsToBounds = true
    }
    
    private let speechField = SpeechField(type: .gray)
    
    let verifyPhotoButton = CTAButton(style: .gray900).then {
        $0.setTitle("인증하고 불조각 받기", for: .normal)
        $0.setImage(UIImage(resource: .icCamera), for: .normal)
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
        addSubviews(backgroundImageView, headerView, journeyTimeView, kkubiCharacterImageView, goToNextButton, speechField, verifyPhotoButton)
    }
    
    override func setLayout() {
        backgroundImageView.snp.makeConstraints {
            $0.width.equalTo(410)
            $0.height.equalTo(437)
            $0.top.equalToSuperview().offset(106)
            $0.leading.equalToSuperview().offset(-17)
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
            $0.height.equalTo(50)
        }
        
        speechField.snp.makeConstraints {
            $0.bottom.equalTo(verifyPhotoButton.snp.top).offset(-27)
            $0.horizontalEdges.equalToSuperview()
        }
        
        goToNextButton.snp.makeConstraints {
            $0.bottom.equalTo(speechField.snp.top).offset(14)
            $0.trailing.equalToSuperview().offset(-24.5)
            $0.width.equalTo(89)
            $0.height.equalTo(24)
        }
        
        kkubiCharacterImageView.snp.makeConstraints {
            $0.top.equalTo(journeyTimeView.snp.bottom).offset(20)
            $0.bottom.equalTo(speechField.snp.top).offset(-20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(343)
        }
    }
    
    // MARK: - Update Methods
    
    func updateData(with data: DailyJourneyModel) {
        headerView.configure(
            kidName: data.kidName,
            date: data.dateText,
            coinCount: data.coinCount,
            fireStoneCount: data.fireStoneCount,
            maxFireStoneCount: data.maxFireStoneCount
        )
        
        journeyTimeView.configure(
            title: "\(data.scheduleOrderText)번째 여정 시간",
            time: data.journeyTimeText
        )
        
        if let url = Bundle.main.url(forResource: data.kkubiImageName, withExtension: "gif") {
            let resource = LocalFileImageDataProvider(fileURL: url)
            kkubiCharacterImageView.kf.setImage(
                with: resource,
                options: [
                    .scaleFactor(UIScreen.main.scale),
                    .cacheOriginalImage,
                    .transition(.fade(0.2))
                ]
            )
        } else {
            kkubiCharacterImageView.image = UIImage(resource: .imgGoblinKid)
            print("gif 경로 못 찾음")
        }
        
        let lines = data.bubbleText.components(separatedBy: "\n")
        
        speechField.configure(
            name: "꾸비",
            lines: lines,
            highlightKeywords: data.highlightKeywords
        )
        
        verifyPhotoButton.isEnabled = data.isMissionActive
        verifyPhotoButton.backgroundColor = data.isMissionActive ? .gray900 : .gray400
    }
}
