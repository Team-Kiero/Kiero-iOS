//
//  GiveFireStoneView.swift
//  Kiero
//
//  Created by Hyunseo Han on 1/16/26.
//

import UIKit

import SnapKit
import Then

final class GiveFireStoneView: BaseUIView {
    
    var didTapBackButton: (() -> Void)?
    var didTapGiveButton: (() -> Void)?
    
    // MARK: - UI Components
    
    private let headerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    private let backButton = UIButton().then {
        let image = UIImage(resource: .icLeft)
        $0.setImage(image, for: .normal)
        $0.tintColor = .white
    }
    
    private let dateLabel = UILabel().then {
        $0.textColor = .gray500
        $0.textAlignment = .center
    }
    
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
        gradientLayer.endPoint = CGPoint(x: 0.8, y: 0.8)
        gradientLayer.locations = [0.0, 1.0]
        
        $0.layer.addSublayer(gradientLayer)
    }
    
    private let giveSpeechBubble = SpeechBubble(speech: "불조각을 나에게 건네줘!")
    
    private let kkubiImageView = UIImageView().then {
        $0.image = UIImage(resource: .imgGoblinKid)
        $0.contentMode = .scaleAspectFit
    }
    
    private let nameView = UIView().then {
        $0.backgroundColor = UIColor(resource: .gray900)
        $0.layer.cornerRadius = 12
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.white.cgColor
        $0.clipsToBounds = true
    }
    
    private let nameLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.setTypo(.body5_10_R, text: "꾸비")
    }
    
    private let giveFireButton = UIButton(type: .custom).then {
        $0.backgroundColor = UIColor(resource: .gray900)
        $0.layer.cornerRadius = 16
    }
    
    private let fireIconImageView = UIImageView().then {
        $0.image = UIImage(resource: .icFireMint)
        $0.contentMode = .scaleAspectFit
    }
    
    private let fireCountLabel = UILabel().then {
        $0.textColor = .gray500
        $0.setTypo(.body2_16_R, text: "7개")
    }
    
    private let fireActionLabel = UILabel().then {
        $0.textColor = .white
        $0.setTypo(.title3_16_SB, text: "불 조각 건네주기")    }
    
    // MARK: - Life Cycle
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundMaskView.frame = backgroundImageView.bounds
        
        if let gradientLayer = backgroundMaskView.layer.sublayers?.first as? CAGradientLayer {
            let sideLength = max(backgroundImageView.bounds.width, backgroundImageView.bounds.height)
            
            gradientLayer.frame = CGRect(x: 0, y: 0, width: sideLength, height: sideLength)
            
            let screenCenter = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            let centerInImage = self.convert(screenCenter, to: backgroundImageView)
            
            let yOffset: CGFloat = 50 // 100
            let targetCenter = CGPoint(x: centerInImage.x, y: centerInImage.y - yOffset)
            
            gradientLayer.position = targetCenter
            
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 0.85, y: 0.85)
        }
        backgroundImageView.mask = backgroundMaskView
    }
    
    // MARK: - Setup Methods
    
    override func setUI() {
        addSubviews(backgroundImageView, kkubiImageView, giveSpeechBubble, nameView, giveFireButton, headerView)
        
        headerView.addSubviews(backButton, dateLabel)
        nameView.addSubview(nameLabel)
        giveFireButton.addSubviews(fireIconImageView, fireCountLabel, fireActionLabel)
        
        giveFireButton.addTarget(self, action: #selector(handleGiveButtonTap), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(handleBackTap), for: .touchUpInside)
        
        setTodayDate()
    }
    
    override func setLayout() {
        headerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(32)
            $0.top.equalToSuperview().offset(54)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24)
        }
        
        dateLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        backgroundImageView.snp.makeConstraints {
            $0.width.equalTo(483)
            $0.height.equalTo(508)
            $0.leading.equalToSuperview().offset(-54)
            $0.top.equalToSuperview().offset(102)
        }
        
        giveSpeechBubble.snp.makeConstraints {
            $0.top.equalToSuperview().offset(200)
            $0.centerX.equalToSuperview()
        }
        
        kkubiImageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(11)
            $0.bottom.equalToSuperview().offset(-350)
            $0.width.equalTo(272)
            $0.height.equalTo(272)
        }
        
        nameView.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-342)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(59)
            $0.height.equalTo(22)
        }
        
        nameLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        giveFireButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(81)
            $0.bottom.equalToSuperview().offset(-141)
        }
        
        fireIconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.centerX.equalToSuperview().offset(-15)
            $0.size.equalTo(18)
        }
        
        fireCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(fireIconImageView)
            $0.leading.equalTo(fireIconImageView.snp.trailing).offset(4)
        }
        
        fireActionLabel.snp.makeConstraints {
            $0.top.equalTo(fireIconImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
        }
    }
    
    private func setTodayDate() {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일 EEEE"
        dateLabel.setTypo(.body3_14_R, text: formatter.string(from: Date()))
    }
    
    @objc
    private func handleGiveButtonTap() {
        didTapGiveButton?()
    }
    
    @objc
    private func handleBackTap() {
        didTapBackButton?()
    }
}
